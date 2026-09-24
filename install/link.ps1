[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $UserHome,

    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Warning 'link.ps1 is retained for compatibility; installation is now copy-based. Use copy.ps1.'

$copyArguments = @{ UserHome = $UserHome; Force = $Force }
if ($WhatIfPreference) {
    $copyArguments.WhatIf = $true
}

& (Join-Path $PSScriptRoot 'copy.ps1') @copyArguments
