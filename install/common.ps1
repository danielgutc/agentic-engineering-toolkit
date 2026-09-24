Set-StrictMode -Version Latest

function Get-NormalizedPath {
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    return [System.IO.Path]::GetFullPath($Path).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
}

function Test-PathEqual {
    param(
        [Parameter(Mandatory)]
        [string] $Left,

        [Parameter(Mandatory)]
        [string] $Right
    )

    $comparison = if ($IsWindows) {
        [System.StringComparison]::OrdinalIgnoreCase
    }
    else {
        [System.StringComparison]::Ordinal
    }

    return [string]::Equals(
        (Get-NormalizedPath -Path $Left),
        (Get-NormalizedPath -Path $Right),
        $comparison
    )
}

function Get-ToolkitLinks {
    param(
        [Parameter(Mandatory)]
        [string] $InstallDirectory,

        [string] $UserHome
    )

    $repositoryRoot = Get-NormalizedPath -Path (Join-Path $InstallDirectory '..')
    $manifestPath = Join-Path $InstallDirectory 'links.json'
    if ([string]::IsNullOrWhiteSpace($UserHome)) {
        $UserHome = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
    }

    if ([string]::IsNullOrWhiteSpace($UserHome)) {
        throw 'Unable to resolve the user profile directory.'
    }

    $userRoot = Get-NormalizedPath -Path $UserHome
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json

    foreach ($entry in $manifest.links) {
        [PSCustomObject]@{
            Name = [string] $entry.name
            Kind = [string] $entry.kind
            Source = Get-NormalizedPath -Path (Join-Path $repositoryRoot $entry.source)
            Target = Get-NormalizedPath -Path (Join-Path $userRoot $entry.target)
        }
    }
}

function Get-LinkDestination {
    param(
        [Parameter(Mandatory)]
        [System.IO.FileSystemInfo] $Item
    )

    if ([string]::IsNullOrWhiteSpace([string] $Item.LinkType)) {
        return $null
    }

    $rawTarget = @($Item.Target)[0]
    if ([string]::IsNullOrWhiteSpace([string] $rawTarget)) {
        return $null
    }

    if ([System.IO.Path]::IsPathRooted($rawTarget)) {
        return Get-NormalizedPath -Path $rawTarget
    }

    $parent = Split-Path -Parent $Item.FullName
    return Get-NormalizedPath -Path (Join-Path $parent $rawTarget)
}

function Get-ToolkitLinkState {
    param(
        [Parameter(Mandatory)]
        [PSCustomObject] $Link
    )

    $targetItem = Get-Item -LiteralPath $Link.Target -Force -ErrorAction SilentlyContinue
    if ($null -eq $targetItem) {
        if (Test-Path -LiteralPath $Link.Source) {
            return 'NotInstalled'
        }

        return 'MissingSource'
    }

    if ([string]::IsNullOrWhiteSpace([string] $targetItem.LinkType)) {
        return 'Conflict'
    }

    $destination = Get-LinkDestination -Item $targetItem
    if ($null -eq $destination -or -not (Test-PathEqual -Left $destination -Right $Link.Source)) {
        return 'WrongTarget'
    }

    if (-not (Test-Path -LiteralPath $Link.Source)) {
        return 'LinkedSourceMissing'
    }

    return 'Linked'
}

function Get-ToolkitDirectoryFingerprint {
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    $root = Get-NormalizedPath -Path $Path
    foreach ($item in Get-ChildItem -LiteralPath $root -Recurse -Force | Sort-Object FullName) {
        $relativePath = [System.IO.Path]::GetRelativePath($root, $item.FullName).Replace('\', '/')
        if ($item.PSIsContainer) {
            "D|$relativePath"
        }
        else {
            $hash = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash
            "F|$relativePath|$hash"
        }
    }
}

function Get-ToolkitCopyState {
    param(
        [Parameter(Mandatory)]
        [PSCustomObject] $Link
    )

    $sourceType = if ($Link.Kind -eq 'directory') { 'Container' } else { 'Leaf' }
    if (-not (Test-Path -LiteralPath $Link.Source -PathType $sourceType)) {
        return 'MissingSource'
    }

    $targetItem = Get-Item -LiteralPath $Link.Target -Force -ErrorAction SilentlyContinue
    if ($null -eq $targetItem) {
        return 'NotInstalled'
    }

    if (-not [string]::IsNullOrWhiteSpace([string] $targetItem.LinkType)) {
        $destination = Get-LinkDestination -Item $targetItem
        if ($null -ne $destination -and (Test-PathEqual -Left $destination -Right $Link.Source)) {
            return 'NeedsCopy'
        }

        return 'WrongTarget'
    }

    if (($Link.Kind -eq 'file' -and $targetItem.PSIsContainer) -or ($Link.Kind -eq 'directory' -and -not $targetItem.PSIsContainer)) {
        return 'Conflict'
    }

    if ($Link.Kind -eq 'directory') {
        $sourceFingerprint = @(Get-ToolkitDirectoryFingerprint -Path $Link.Source)
        $targetFingerprint = @(Get-ToolkitDirectoryFingerprint -Path $Link.Target)
        if ($sourceFingerprint.Count -eq $targetFingerprint.Count -and ($sourceFingerprint -join "`n") -ceq ($targetFingerprint -join "`n")) {
            return 'Copied'
        }

        return 'Outdated'
    }

    $sourceHash = (Get-FileHash -LiteralPath $Link.Source -Algorithm SHA256).Hash
    $targetHash = (Get-FileHash -LiteralPath $Link.Target -Algorithm SHA256).Hash
    if ($sourceHash -ceq $targetHash) {
        return 'Copied'
    }

    return 'Outdated'
}
