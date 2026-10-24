[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$routingPaths = @(
    (Join-Path $repositoryRoot '.codex/AGENTS.md'),
    (Join-Path $repositoryRoot '.github/copilot-instructions.md')
)
$errors = [System.Collections.Generic.List[string]]::new()

foreach ($path in $routingPaths) {
    $content = Get-Content -LiteralPath $path -Raw
    foreach ($phrase in @(
            'coordinator responsible for routing, ownership, and user approval gates',
            'concise conclusions, evidence, risks or assumptions, and owner actions',
            'optional `role-collaboration` module'
        )) {
        if ($content -notmatch [regex]::Escape($phrase)) {
            $errors.Add("$([System.IO.Path]::GetFileName($path)) is missing '$phrase'.")
        }
    }
}

foreach ($agent in Get-ChildItem -LiteralPath (Join-Path $repositoryRoot '.codex/agents') -File -Filter '*.toml') {
    $content = Get-Content -LiteralPath $agent.FullName -Raw
    if ($content -match '\$role-collaboration|consultation_needed|clarification_needed') {
        $errors.Add("$($agent.Name) contains optional collaboration protocol mechanics.")
    }
}

if ($errors.Count -gt 0) {
    throw "Handoff contract validation failed:`n- $($errors -join "`n- ")"
}

Write-Host 'Validated generic coordinator fallback without hard optional-module mechanics.'
