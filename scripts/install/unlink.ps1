[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $UserHome,

    [string] $Feature,

    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'common.ps1')

$links = @(Get-ToolkitLinks -InstallDirectory $PSScriptRoot -UserHome $UserHome)
if (-not [string]::IsNullOrWhiteSpace($Feature)) {
    if ($Feature -notmatch '^[a-z0-9-]+$') {
        throw "Invalid feature identifier: $Feature"
    }

    $links = @($links | Where-Object { $_.Feature -ceq $Feature })
    if ($links.Count -eq 0) {
        throw "Unknown optional feature: $Feature"
    }
}
elseif ($Force) {
    throw '-Force requires an explicit -Feature selection.'
}

$resolvedUserHome = if ([string]::IsNullOrWhiteSpace($UserHome)) {
    Get-NormalizedPath -Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile))
}
else {
    Get-NormalizedPath -Path $UserHome
}
$skillsRoot = Get-NormalizedPath -Path (Join-Path $resolvedUserHome '.agents/skills')

foreach ($link in $links) {
    $state = Get-ToolkitCopyState -Link $link
    $skipRemoval = $false

    switch ($state) {
        'NotInstalled' {
            Write-Host "Not installed: $($link.Target)"
            $skipRemoval = $true
        }
        'MissingSource' {
            Write-Host "Not installed: $($link.Target)"
            $skipRemoval = $true
        }
        'Conflict' {
            Write-Warning "Skipped non-managed target: $($link.Target)"
            $skipRemoval = $true
        }
        'WrongTarget' {
            Write-Warning "Skipped link owned by another source: $($link.Target)"
            $skipRemoval = $true
        }
        'Outdated' {
            if (-not ($Force -and -not [string]::IsNullOrWhiteSpace($Feature))) {
                Write-Warning "Skipped modified copy: $($link.Target)"
                $skipRemoval = $true
            }
        }
        'OrphanedOptionalSource' {
            if (-not ($Force -and -not [string]::IsNullOrWhiteSpace($Feature))) {
                Write-Warning "Skipped orphaned optional copy without -Feature $($link.Feature) -Force: $($link.Target)"
                $skipRemoval = $true
            }
        }
    }

    if ($skipRemoval) {
        continue
    }

    if ($PSCmdlet.ShouldProcess($link.Target, 'Remove toolkit installation')) {
        if ($link.Kind -eq 'directory') {
            $resolvedTarget = Get-NormalizedPath -Path $link.Target
            $requiredPrefix = $skillsRoot + [System.IO.Path]::DirectorySeparatorChar
            if (-not $resolvedTarget.StartsWith($requiredPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                throw "Refusing to remove a directory outside the managed skills root: $resolvedTarget"
            }

            $targetItem = Get-Item -LiteralPath $resolvedTarget -Force -ErrorAction Stop
            if (-not [string]::IsNullOrWhiteSpace([string] $targetItem.LinkType)) {
                if ($state -eq 'NeedsCopy') {
                    Remove-Item -LiteralPath $resolvedTarget -Force
                    Write-Host "Removed: $($link.Target)"
                    continue
                }

                throw "Refusing to remove a linked directory: $resolvedTarget"
            }

            Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
        }
        else {
            Remove-Item -LiteralPath $link.Target -Force
        }
        Write-Host "Removed: $($link.Target)"
    }
}
