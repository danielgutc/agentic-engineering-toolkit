[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$checks = @(
    'validate-powershell.ps1',
    'validate-agents.ps1',
    'validate-skills.ps1',
    'validate-links.ps1'
)

foreach ($check in $checks) {
    Write-Host "Running $check"
    & (Join-Path $PSScriptRoot $check)
}

Write-Host 'All toolkit validation checks passed.'
