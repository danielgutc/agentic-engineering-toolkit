[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $UserHome,

    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'common.ps1')

$items = @(Get-ToolkitLinks -InstallDirectory $PSScriptRoot -UserHome $UserHome)
$states = @{}

foreach ($item in $items) {
    $state = Get-ToolkitCopyState -Link $item
    $states[$item.Target] = $state

    switch ($state) {
        'Copied' { continue }
        'NotInstalled' { continue }
        'NeedsCopy' { continue }
        'Outdated' {
            if ($Force) {
                continue
            }

            throw "Cannot refresh '$($item.Name)': target differs from the toolkit source. Re-run with -Force to replace it: $($item.Target)"
        }
        'MissingSource' { throw "Cannot copy '$($item.Name)': source does not exist: $($item.Source)" }
        'Conflict' { throw "Cannot copy '$($item.Name)': target has the wrong filesystem type: $($item.Target)" }
        'WrongTarget' { throw "Cannot copy '$($item.Name)': target is a link managed by another source: $($item.Target)" }
    }
}

foreach ($item in $items) {
    $state = $states[$item.Target]
    if ($state -eq 'Copied') {
        Write-Host "Already copied: $($item.Target)"
        continue
    }

    if ($PSCmdlet.ShouldProcess($item.Target, "Copy from $($item.Source)")) {
        $targetParent = Split-Path -Parent $item.Target
        if (-not (Test-Path -LiteralPath $targetParent)) {
            New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
        }

        if ($state -eq 'NeedsCopy') {
            Remove-Item -LiteralPath $item.Target -Force
        }
        elseif ($state -eq 'Outdated' -and $item.Kind -eq 'directory') {
            $resolvedUserHome = if ([string]::IsNullOrWhiteSpace($UserHome)) {
                Get-NormalizedPath -Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile))
            }
            else {
                Get-NormalizedPath -Path $UserHome
            }
            $skillsRoot = Get-NormalizedPath -Path (Join-Path $resolvedUserHome '.agents/skills')
            $resolvedTarget = Get-NormalizedPath -Path $item.Target
            $requiredPrefix = $skillsRoot + [System.IO.Path]::DirectorySeparatorChar
            if (-not $resolvedTarget.StartsWith($requiredPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                throw "Refusing to replace a directory outside the managed skills root: $resolvedTarget"
            }

            Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
        }

        if ($item.Kind -eq 'directory') {
            Copy-Item -LiteralPath $item.Source -Destination $item.Target -Recurse -Force
        }
        else {
            Copy-Item -LiteralPath $item.Source -Destination $item.Target -Force
        }

        if ((Get-ToolkitCopyState -Link $item) -ne 'Copied') {
            throw "Copy verification failed for '$($item.Name)': $($item.Target)"
        }

        Write-Host "Copied: $($item.Target)"
    }
}
