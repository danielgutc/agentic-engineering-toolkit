[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$manifest = Get-Content -LiteralPath (Join-Path $repositoryRoot 'install/links.json') -Raw | ConvertFrom-Json
$optionalLinks = @($manifest.links | Where-Object { $_.PSObject.Properties.Name -contains 'optional' -and $_.optional -eq $true })

foreach ($link in $optionalLinks) {
    $sourcePath = Join-Path $repositoryRoot $link.source
    if (-not (Test-Path -LiteralPath $sourcePath)) {
        continue
    }

    $validator = Join-Path $sourcePath 'tests/validate.ps1'
    if (-not (Test-Path -LiteralPath $validator -PathType Leaf)) {
        throw "Optional module '$($link.feature)' has no module validator: $validator"
    }

    & $validator -RepositoryRoot $repositoryRoot
}

Write-Host "Validated $($optionalLinks.Count) optional module definitions."
