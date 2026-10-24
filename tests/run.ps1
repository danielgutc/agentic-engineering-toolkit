[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$checks = @(
    'validate-powershell.ps1',
    'validate-agents.ps1',
    'validate-agent-sync.ps1',
    'validate-skills.ps1',
    'validate-optional-modules.ps1',
    'validate-optional-install.ps1',
    'validate-handoff-contract.ps1',
    'validate-workspace-guidance.ps1',
    'validate-links.ps1'
)

foreach ($check in $checks) {
    Write-Host "Running $check"
    & (Join-Path $PSScriptRoot $check)
}

Write-Host 'All toolkit validation checks passed.'
