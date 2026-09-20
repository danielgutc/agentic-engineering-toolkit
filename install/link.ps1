[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $UserHome
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'common.ps1')

$links = @(Get-ToolkitLinks -InstallDirectory $PSScriptRoot -UserHome $UserHome)

foreach ($link in $links) {
    $state = Get-ToolkitLinkState -Link $link

    switch ($state) {
        'Linked' {
            Write-Host "Already linked: $($link.Target)"
            continue
        }
        'MissingSource' {
            throw "Cannot install '$($link.Name)': source does not exist: $($link.Source)"
        }
        'LinkedSourceMissing' {
            throw "Cannot install '$($link.Name)': an existing link points to a missing source: $($link.Target)"
        }
        'Conflict' {
            throw "Cannot install '$($link.Name)': target is an existing file or directory: $($link.Target)"
        }
        'WrongTarget' {
            throw "Cannot install '$($link.Name)': target is already a link managed by another source: $($link.Target)"
        }
    }

    $targetParent = Split-Path -Parent $link.Target
    if (-not (Test-Path -LiteralPath $targetParent)) {
        if ($PSCmdlet.ShouldProcess($targetParent, 'Create target directory')) {
            New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
        }
    }

    if ($PSCmdlet.ShouldProcess($link.Target, "Link to $($link.Source)")) {
        New-Item -ItemType SymbolicLink -Path $link.Target -Target $link.Source | Out-Null
        Write-Host "Linked: $($link.Target) -> $($link.Source)"
    }
}
