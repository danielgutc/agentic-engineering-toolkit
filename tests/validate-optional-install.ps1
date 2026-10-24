[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("toolkit-optional-install-" + [guid]::NewGuid().ToString('N'))
function Assert-TemporaryPath {
    param([string] $Path)
    $rootPath = [System.IO.Path]::GetFullPath($temporaryRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
    $root = $rootPath + [System.IO.Path]::DirectorySeparatorChar
    $candidate = [System.IO.Path]::GetFullPath($Path)
    if (-not ($candidate -eq $rootPath -or $candidate.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase))) {
        throw "Refusing to delete outside the temporary fixture: $candidate"
    }
}
try {
    $installRoot = Join-Path $temporaryRoot 'install'
    $userHome = Join-Path $temporaryRoot 'user'
    $moduleSource = Join-Path $temporaryRoot 'optional-module'
    $requiredSource = Join-Path $temporaryRoot 'required.txt'
    New-Item -ItemType Directory -Path $installRoot, $moduleSource -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $moduleSource 'module.txt') -Value 'optional' -NoNewline
    Set-Content -LiteralPath $requiredSource -Value 'required' -NoNewline
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'install/common.ps1') -Destination $installRoot
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'install/copy.ps1') -Destination $installRoot
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'install/status.ps1') -Destination $installRoot
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'install/unlink.ps1') -Destination $installRoot
    @'
{
  "links": [
    { "name": "required", "kind": "file", "source": "required.txt", "target": ".codex/required.txt" },
    { "name": "optional", "kind": "directory", "source": "optional-module", "target": ".agents/skills/optional-module", "optional": true, "feature": "role-collaboration" }
  ]
}
'@ | Set-Content -LiteralPath (Join-Path $installRoot 'links.json') -NoNewline

    & (Join-Path $installRoot 'copy.ps1') -UserHome $userHome
    $optionalTarget = Join-Path $userHome '.agents/skills/optional-module'
    $requiredTarget = Join-Path $userHome '.codex/required.txt'
    if (-not (Test-Path -LiteralPath $optionalTarget -PathType Container) -or -not (Test-Path -LiteralPath $requiredTarget -PathType Leaf)) {
        throw 'Initial isolated installation did not copy required and optional entries.'
    }

    Assert-TemporaryPath -Path $moduleSource
    Remove-Item -LiteralPath $moduleSource -Recurse -Force
    & (Join-Path $installRoot 'copy.ps1') -UserHome $userHome
    $status = & (Join-Path $installRoot 'status.ps1') -UserHome $userHome 2>&1
    . (Join-Path $installRoot 'common.ps1')
    $optionalLink = @(Get-ToolkitLinks -InstallDirectory $installRoot -UserHome $userHome | Where-Object { $_.Feature -eq 'role-collaboration' })[0]
    if ($LASTEXITCODE -eq 0 -or (Get-ToolkitCopyState -Link $optionalLink) -ne 'OrphanedOptionalSource') {
        throw 'Missing optional source with installed copy must be reported as an orphaned optional source.'
    }
    if (-not (Test-Path -LiteralPath $optionalTarget -PathType Container)) {
        throw 'Missing optional source must preserve its installed copy until targeted removal.'
    }

    Assert-TemporaryPath -Path $optionalTarget
    Remove-Item -LiteralPath $optionalTarget -Recurse -Force
    Set-Content -LiteralPath $optionalTarget -Value 'unrelated wrong type' -NoNewline
    & (Join-Path $installRoot 'unlink.ps1') -UserHome $userHome -Feature role-collaboration -Force
    if (-not (Test-Path -LiteralPath $optionalTarget -PathType Leaf)) {
        throw 'Scoped removal must not delete a wrong-type target when an optional source is absent.'
    }

    Remove-Item -LiteralPath $optionalTarget -Force
    New-Item -ItemType Directory -Path $optionalTarget -Force | Out-Null
    & (Join-Path $installRoot 'unlink.ps1') -UserHome $userHome -Feature role-collaboration -Force
    if (Test-Path -LiteralPath $optionalTarget) {
        throw 'Targeted forced feature removal did not remove the orphaned optional copy.'
    }
    if (-not (Test-Path -LiteralPath $requiredTarget -PathType Leaf)) {
        throw 'Targeted feature removal changed an unrelated installed file.'
    }

    try {
        & (Join-Path $installRoot 'unlink.ps1') -UserHome $userHome -Feature '../required' -Force
        throw 'Path-like feature identifiers must be rejected.'
    }
    catch {
        if ($_.Exception.Message -notmatch 'Invalid feature identifier') {
            throw
        }
    }
}
finally {
    if (Test-Path -LiteralPath $temporaryRoot) {
        Assert-TemporaryPath -Path $temporaryRoot
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    }
}

Write-Host 'Validated isolated optional installation, orphan reporting, and scoped removal.'
