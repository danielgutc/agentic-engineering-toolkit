[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $UserHome
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'common.ps1')

foreach ($link in Get-ToolkitLinks -InstallDirectory $PSScriptRoot -UserHome $UserHome) {
    $state = Get-ToolkitCopyState -Link $link

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
            Write-Warning "Skipped non-managed target: $($link.Target)"
            continue
        }
        'WrongTarget' {
            Write-Warning "Skipped link owned by another source: $($link.Target)"
            continue
        }
        'Outdated' {
            Write-Warning "Skipped modified agent copy: $($link.Target)"
            continue
        }
    }

    if ($PSCmdlet.ShouldProcess($link.Target, 'Remove toolkit installation')) {
        if ($link.Kind -eq 'directory' -and $state -eq 'Copied') {
            $resolvedUserHome = if ([string]::IsNullOrWhiteSpace($UserHome)) {
                Get-NormalizedPath -Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile))
            }
            else {
                Get-NormalizedPath -Path $UserHome
            }
            $skillsRoot = Get-NormalizedPath -Path (Join-Path $resolvedUserHome '.agents/skills')
            $resolvedTarget = Get-NormalizedPath -Path $link.Target
            $requiredPrefix = $skillsRoot + [System.IO.Path]::DirectorySeparatorChar
            if (-not $resolvedTarget.StartsWith($requiredPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                throw "Refusing to remove a directory outside the managed skills root: $resolvedTarget"
            }

            Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
        }
        else {
            Remove-Item -LiteralPath $link.Target -Force
        }
        Write-Host "Removed: $($link.Target)"
    }
}
