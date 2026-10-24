[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$skillPath = Join-Path $repositoryRoot '.agents/skills/role-collaboration/SKILL.md'
$routingPaths = @(
    (Join-Path $repositoryRoot '.codex/AGENTS.md'),
    (Join-Path $repositoryRoot '.github/copilot-instructions.md')
)
$errors = [System.Collections.Generic.List[string]]::new()
$skill = Get-Content -LiteralPath $skillPath -Raw

$requiredHandoffFields = @(
    'Approved scope:',
    'Requirement IDs:',
    'Prior role decisions:',
    'Open questions:',
    'Exact deliverable:',
    'Next owner:',
    'Relevant artifact summary:',
    'Requested model:'
)
$requiredResponseFields = @(
    'Conclusion:',
    'Evidence:',
    'Risks or assumptions:',
    'Owner action:',
    'Reported model:'
)

foreach ($field in $requiredHandoffFields) {
    if ($skill -notmatch [regex]::Escape($field)) {
        $errors.Add("Role collaboration contract is missing '$field'.")
    }
}

foreach ($field in $requiredResponseFields) {
    if ($skill -notmatch [regex]::Escape($field)) {
        $errors.Add("Role collaboration response is missing '$field'.")
    }
}

if ($skill -notmatch '(?s)Requested model:.*?Reported model:' -or
    $skill -notmatch 'Never infer the reported model from the requested model') {
    $errors.Add('Requested and reported models must be separate and must not be inferred from one another.')
}

foreach ($phrase in @(
        'only the relevant artifact summary',
        'wait for approval before advancing',
        'preserve request and parent request IDs',
        'relay the child''s concise answer and evidence back to the original requesting role'
    )) {
    if ($skill -notmatch [regex]::Escape($phrase)) {
        $errors.Add("Role collaboration flow is missing '$phrase'.")
    }
}

foreach ($path in $routingPaths) {
    $content = Get-Content -LiteralPath $path -Raw
    if ($content -notmatch 'shared role-collaboration handoff contract') {
        $errors.Add("$([System.IO.Path]::GetFileName($path)) does not require the shared handoff contract.")
    }
    if ($content -notmatch 'Record requested and reported models separately') {
        $errors.Add("$([System.IO.Path]::GetFileName($path)) does not require separate model reporting.")
    }
}

if ($errors.Count -gt 0) {
    throw "Handoff contract validation failed:`n- $($errors -join "`n- ")"
}

Write-Host 'Validated shared handoff, approval, nested-consultation, and model-reporting requirements.'
