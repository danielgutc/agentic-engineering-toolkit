[CmdletBinding(SupportsShouldProcess)]
param(
    [switch] $Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$codexAgentRoot = Join-Path $repositoryRoot '.codex/agents'
$copilotAgentRoot = Join-Path $repositoryRoot '.github/agents'

function Get-TomlStringValue {
    param(
        [Parameter(Mandatory)]
        [string] $Content,

        [Parameter(Mandatory)]
        [string] $Key
    )

    $pattern = '(?m)^{0}\s*=\s*"(?<value>[^"]*)"\s*$' -f [regex]::Escape($Key)
    $match = [regex]::Match($Content, $pattern)
    if (-not $match.Success) {
        throw "Unable to read '$Key' from a Codex agent definition."
    }

    return $match.Groups['value'].Value
}

function ConvertTo-YamlString {
    param(
        [Parameter(Mandatory)]
        [string] $Value
    )

    return "'" + $Value.Replace("'", "''") + "'"
}

function Get-CopilotAgentContent {
    param(
        [Parameter(Mandatory)]
        [System.IO.FileInfo] $CodexAgent
    )

    $content = Get-Content -LiteralPath $CodexAgent.FullName -Raw
    $description = Get-TomlStringValue -Content $content -Key 'description'
    $model = Get-TomlStringValue -Content $content -Key 'model'
    $reasoningEffort = Get-TomlStringValue -Content $content -Key 'model_reasoning_effort'
    $instructionsMatch = [regex]::Match(
        $content,
        '(?ms)^developer_instructions\s*=\s*"""\r?\n(?<value>.*?)\r?\n"""\s*$'
    )
    if (-not $instructionsMatch.Success) {
        throw "Unable to read developer_instructions from $($CodexAgent.Name)."
    }

    $instructions = $instructionsMatch.Groups['value'].Value.Replace("`r`n", "`n").TrimEnd()
    $canonicalSource = ".codex/agents/$($CodexAgent.Name)"
    $lines = @(
        '---'
        "name: $(ConvertTo-YamlString -Value $CodexAgent.BaseName)"
        "description: $(ConvertTo-YamlString -Value $description)"
        "tools: ['*']"
        'include-custom-instructions: true'
        "reasoningEffort: $(ConvertTo-YamlString -Value $reasoningEffort)"
        'metadata:'
        "  canonical-source: $(ConvertTo-YamlString -Value $canonicalSource)"
        "  canonical-model: $(ConvertTo-YamlString -Value $model)"
        '---'
        ''
        $instructions
        ''
    )

    return $lines -join "`n"
}

$codexAgents = @(Get-ChildItem -LiteralPath $codexAgentRoot -File -Filter '*.toml' | Sort-Object Name)
$expectedFiles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$errors = [System.Collections.Generic.List[string]]::new()

foreach ($codexAgent in $codexAgents) {
    $targetName = "$($codexAgent.BaseName).agent.md"
    [void] $expectedFiles.Add($targetName)
    $targetPath = Join-Path $copilotAgentRoot $targetName
    $expectedContent = Get-CopilotAgentContent -CodexAgent $codexAgent

    if ($Check) {
        if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
            $errors.Add("Missing Copilot agent clone: .github/agents/$targetName")
            continue
        }

        $actualContent = (Get-Content -LiteralPath $targetPath -Raw).Replace("`r`n", "`n")
        if ($actualContent -cne $expectedContent) {
            $errors.Add("Copilot agent is not synchronized: .github/agents/$targetName")
        }

        continue
    }

    if (-not (Test-Path -LiteralPath $copilotAgentRoot -PathType Container)) {
        New-Item -ItemType Directory -Path $copilotAgentRoot -Force | Out-Null
    }

    if ($PSCmdlet.ShouldProcess($targetPath, "Generate from $($codexAgent.Name)")) {
        Set-Content -LiteralPath $targetPath -Value $expectedContent -Encoding utf8 -NoNewline
        Write-Host "Synchronized: .github/agents/$targetName"
    }
}

if (Test-Path -LiteralPath $copilotAgentRoot -PathType Container) {
    foreach ($copilotAgent in Get-ChildItem -LiteralPath $copilotAgentRoot -File -Filter '*.agent.md') {
        if ($expectedFiles.Contains($copilotAgent.Name)) {
            continue
        }

        if ($Check) {
            $errors.Add("Copilot agent has no canonical Codex definition: .github/agents/$($copilotAgent.Name)")
        }
        elseif ($PSCmdlet.ShouldProcess($copilotAgent.FullName, 'Remove stale generated Copilot agent')) {
            Remove-Item -LiteralPath $copilotAgent.FullName -Force
            Write-Host "Removed stale clone: .github/agents/$($copilotAgent.Name)"
        }
    }
}

if ($errors.Count -gt 0) {
    throw "Agent synchronization validation failed:`n- $($errors -join "`n- ")"
}

if ($Check) {
    Write-Host "Validated $($codexAgents.Count) synchronized Codex and Copilot agents."
}
