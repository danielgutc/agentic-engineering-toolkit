[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $UserHome
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'common.ps1')

foreach ($link in Get-ToolkitLinks -InstallDirectory $PSScriptRoot -UserHome $UserHome) {
    $state = Get-ToolkitLinkState -Link $link

    switch ($state) {
        'NotInstalled' {
            Write-Host "Not installed: $($link.Target)"
            continue
        }
        'MissingSource' {
            Write-Host "Not installed: $($link.Target)"
            continue
        }
        'Conflict' {
            Write-Warning "Skipped non-link target: $($link.Target)"
            continue
        }
        'WrongTarget' {
            Write-Warning "Skipped link owned by another source: $($link.Target)"
            continue
        }
    }

    if ($PSCmdlet.ShouldProcess($link.Target, 'Remove toolkit link')) {
        Remove-Item -LiteralPath $link.Target -Force
        Write-Host "Unlinked: $($link.Target)"
    }
}
