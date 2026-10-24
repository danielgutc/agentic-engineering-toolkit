[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$manifestPath = Join-Path $repositoryRoot 'install/links.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()
$sources = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$targets = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ($link in $manifest.links) {
    $sourceKey = ([string] $link.source).Replace('\', '/')
    $targetKey = ([string] $link.target).Replace('\', '/')
    $sourcePath = Join-Path $repositoryRoot $link.source

    if (-not $sources.Add($sourceKey)) {
        $errors.Add("Duplicate manifest source: $sourceKey")
    }

    if (-not $targets.Add($targetKey)) {
        $errors.Add("Duplicate manifest target: $targetKey")
    }

    $isOptional = $link.PSObject.Properties.Name -contains 'optional' -and $link.optional -eq $true
    if (-not (Test-Path -LiteralPath $sourcePath) -and -not $isOptional) {
        $errors.Add("Manifest source does not exist: $sourceKey")
    }

    if ($isOptional -and ([string]::IsNullOrWhiteSpace([string] $link.feature) -or $link.feature -notmatch '^[a-z0-9-]+$')) {
        $errors.Add("Optional source must have a safe feature identifier: $sourceKey")
    }

    switch ([string] $link.kind) {
        'file' {
            if (-not (Test-Path -LiteralPath $sourcePath) -and $isOptional) { continue }
            if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
                $errors.Add("File link source is not a file: $sourceKey")
            }
        }
        'directory' {
            if (-not (Test-Path -LiteralPath $sourcePath) -and $isOptional) { continue }
            if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
                $errors.Add("Directory link source is not a directory: $sourceKey")
            }
        }
        default {
            $errors.Add("Unsupported link kind '$($link.kind)' for $sourceKey")
        }
    }
}

$expectedSources = [System.Collections.Generic.List[string]]::new()
$expectedSources.Add('.codex/AGENTS.md')
$expectedSources.Add('.github/copilot-instructions.md')

$routingEntry = @($manifest.links | Where-Object {
    ([string] $_.source).Replace('\', '/') -eq '.codex/AGENTS.md'
})
if ($routingEntry.Count -ne 1 -or ([string] $routingEntry[0].target).Replace('\', '/') -ne '.codex/AGENTS.md' -or $routingEntry[0].kind -ne 'file') {
    $errors.Add('.codex/AGENTS.md must be installed as a file at .codex/AGENTS.md.')
}

$copilotRoutingEntry = @($manifest.links | Where-Object {
    ([string] $_.source).Replace('\', '/') -eq '.github/copilot-instructions.md'
})
if ($copilotRoutingEntry.Count -ne 1 -or ([string] $copilotRoutingEntry[0].target).Replace('\', '/') -ne '.copilot/copilot-instructions.md' -or $copilotRoutingEntry[0].kind -ne 'file') {
    $errors.Add('.github/copilot-instructions.md must be installed as a file at .copilot/copilot-instructions.md.')
}

if (-not (Test-Path -LiteralPath (Join-Path $repositoryRoot 'AGENTS.md') -PathType Leaf)) {
    $errors.Add('Repository-specific AGENTS.md is missing from the repository root.')
}

foreach ($agent in Get-ChildItem -LiteralPath (Join-Path $repositoryRoot '.codex/agents') -File -Filter '*.toml') {
    $expectedSources.Add(".codex/agents/$($agent.Name)")
}

foreach ($agent in Get-ChildItem -LiteralPath (Join-Path $repositoryRoot '.github/agents') -File -Filter '*.agent.md') {
    $expectedSources.Add(".github/agents/$($agent.Name)")
}

foreach ($skill in Get-ChildItem -LiteralPath (Join-Path $repositoryRoot '.agents/skills') -Directory) {
    $expectedSources.Add(".agents/skills/$($skill.Name)")
}

foreach ($expected in $expectedSources) {
    $manifestEntry = @($manifest.links | Where-Object { ([string] $_.source).Replace('\', '/') -eq $expected })
    if ($manifestEntry.Count -eq 1 -and $manifestEntry[0].PSObject.Properties.Name -contains 'optional' -and $manifestEntry[0].optional -eq $true -and -not (Test-Path -LiteralPath (Join-Path $repositoryRoot $expected))) {
        continue
    }
    if (-not $sources.Contains($expected)) {
        $errors.Add("Source is not represented in the link manifest: $expected")
    }
}

foreach ($source in $sources) {
    $manifestEntry = @($manifest.links | Where-Object { ([string] $_.source).Replace('\', '/') -eq $source })
    if ($manifestEntry.Count -eq 1 -and $manifestEntry[0].PSObject.Properties.Name -contains 'optional' -and $manifestEntry[0].optional -eq $true -and -not (Test-Path -LiteralPath (Join-Path $repositoryRoot $source))) {
        continue
    }
    if (-not $expectedSources.Contains($source)) {
        $errors.Add("Manifest contains unmanaged source: $source")
    }
}

if ($errors.Count -gt 0) {
    throw "Link manifest validation failed:`n- $($errors -join "`n- ")"
}

Write-Host "Validated $($manifest.links.Count) installation definitions."
