[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$manifestPath = Join-Path $repositoryRoot 'install/links.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()
$sources = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$targets = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ($link in $manifest.links) {
    $sourceKey = ([string] $link.source).Replace('\', '/')
    $targetKey = ([string] $link.target).Replace('\', '/')
    $sourcePath = Join-Path $repositoryRoot $link.source

    if (-not $sources.Add($sourceKey)) {
        $errors.Add("Duplicate manifest source: $sourceKey")
    }

    if (-not $targets.Add($targetKey)) {
        $errors.Add("Duplicate manifest target: $targetKey")
    }

    if (-not (Test-Path -LiteralPath $sourcePath)) {
        $errors.Add("Manifest source does not exist: $sourceKey")
    }

    switch ([string] $link.kind) {
        'file' {
            if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
                $errors.Add("File link source is not a file: $sourceKey")
            }
        }
        'directory' {
            if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
                $errors.Add("Directory link source is not a directory: $sourceKey")
            }
        }
        default {
            $errors.Add("Unsupported link kind '$($link.kind)' for $sourceKey")
        }
    }
}

$expectedSources = [System.Collections.Generic.List[string]]::new()
foreach ($agent in Get-ChildItem -LiteralPath (Join-Path $repositoryRoot '.codex/agents') -File -Filter '*.toml') {
    $expectedSources.Add(".codex/agents/$($agent.Name)")
}

foreach ($skill in Get-ChildItem -LiteralPath (Join-Path $repositoryRoot '.agents/skills') -Directory) {
    $expectedSources.Add(".agents/skills/$($skill.Name)")
}

foreach ($expected in $expectedSources) {
    if (-not $sources.Contains($expected)) {
        $errors.Add("Source is not represented in the link manifest: $expected")
    }
}

foreach ($source in $sources) {
    if (-not $expectedSources.Contains($source)) {
        $errors.Add("Manifest contains unmanaged source: $source")
    }
}

if ($errors.Count -gt 0) {
    throw "Link manifest validation failed:`n- $($errors -join "`n- ")"
}

Write-Host "Validated $($manifest.links.Count) link definitions."
