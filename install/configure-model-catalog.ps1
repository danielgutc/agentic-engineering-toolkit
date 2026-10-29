[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $UserHome,
    [string] $SourceCatalog,
    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not [string]::IsNullOrWhiteSpace($UserHome)) {
    $codexRoot = Join-Path ([System.IO.Path]::GetFullPath($UserHome)) '.codex'
}
elseif (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
    $codexRoot = [System.IO.Path]::GetFullPath($env:CODEX_HOME)
}
else {
    $codexRoot = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)) '.codex'
}

$destination = Join-Path $codexRoot 'models.toolkit.json'
if ([string]::IsNullOrWhiteSpace($SourceCatalog)) {
    $SourceCatalog = Join-Path $codexRoot 'models_cache.json'
}
$sourcePath = [System.IO.Path]::GetFullPath($SourceCatalog)
if ($sourcePath.Equals($destination, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Source catalog and destination must be different files; use the original catalog or cache.'
}
if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
    throw "Source catalog not found: $sourcePath. Supply -SourceCatalog with the active Codex catalog or cache."
}

$catalog = Get-Content -LiteralPath $sourcePath -Raw | ConvertFrom-Json -AsHashtable -Depth 100
if ($catalog -isnot [System.Collections.IDictionary] -or -not $catalog.Contains('models') -or
    $catalog.models -isnot [array] -or $catalog.models.Count -eq 0) {
    throw 'Source catalog must contain a nonempty models array.'
}
$slugs = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($entry in $catalog.models) {
    if ($entry -isnot [System.Collections.IDictionary] -or -not $entry.Contains('slug') -or
        $entry.slug -isnot [string] -or [string]::IsNullOrWhiteSpace($entry.slug)) {
        throw 'Every source model must have a nonempty string slug.'
    }
}
$qwenEntries = @($catalog.models | Where-Object { $_.slug -ceq 'qwen/qwen3.5-9b' })
if ($qwenEntries.Count -ne 1) {
    throw 'Source catalog must contain exactly one qwen/qwen3.5-9b entry; no model metadata is invented.'
}
foreach ($entry in $catalog.models) {
    if (-not $slugs.Add($entry.slug)) { throw "Duplicate model slug: $($entry.slug)" }
}
$qwen = $qwenEntries[0]
if (-not $qwen.Contains('supported_reasoning_levels') -or $qwen.supported_reasoning_levels -isnot [array]) {
    throw 'Qwen supported_reasoning_levels must be an array.'
}
foreach ($level in $qwen.supported_reasoning_levels) {
    if ($level -isnot [System.Collections.IDictionary] -or -not $level.Contains('effort') -or $level.effort -isnot [string]) {
        throw 'Each Qwen reasoning level must declare a string effort.'
    }
}
$highLevels = @($qwen.supported_reasoning_levels | Where-Object { $_.effort -ceq 'high' })
if ($highLevels.Count -gt 1) { throw 'Duplicate Qwen high reasoning levels.' }
if ($highLevels.Count -eq 0) {
    $qwen.supported_reasoning_levels = @($qwen.supported_reasoning_levels) + @(
        [ordered]@{ effort = 'high'; description = 'High reasoning effort' }
    )
}
$qwen.default_reasoning_level = 'high'
# Strip cache timestamps and identity while preserving all complete model entries.
$output = ([ordered]@{ models = @($catalog.models) } | ConvertTo-Json -Depth 100) + "`n"
$needsWrite = $true
if (Test-Path -LiteralPath $destination) {
    $item = Get-Item -LiteralPath $destination -Force
    if ($item.PSIsContainer -or ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "Destination must be a regular file, not a directory or link: $destination"
    }
    if ([System.IO.File]::ReadAllText($destination) -ceq $output) {
        $needsWrite = $false
    }
    elseif (-not $Force) {
        throw "Destination differs from generated catalog. Re-run with -Force to replace it: $destination"
    }
}

if ($needsWrite -and $PSCmdlet.ShouldProcess($destination, 'Generate Qwen high-reasoning model catalog')) {
    if (-not (Test-Path -LiteralPath $codexRoot)) {
        New-Item -ItemType Directory -Path $codexRoot -Force | Out-Null
    }
    $temporaryPath = Join-Path $codexRoot ('models.toolkit.' + [guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [System.IO.File]::WriteAllText($temporaryPath, $output, [System.Text.UTF8Encoding]::new($false))
        [System.IO.File]::Move($temporaryPath, $destination, [bool] $Force)
    }
    finally {
        if (Test-Path -LiteralPath $temporaryPath) { Remove-Item -LiteralPath $temporaryPath -Force }
    }
    Write-Host "Generated: $destination"
}
elseif (-not $needsWrite) {
    Write-Host "Already generated: $destination"
}

$tomlPath = $destination.Replace('\', '/').Replace('"', '\"')
Write-Host 'To activate after generation, set this at the root of the active Codex config file (before any table headers):'
Write-Host ('model_catalog_json = "{0}"' -f $tomlPath)
Write-Host 'Replace any existing root value; selected profile configuration can override it. Restart Codex afterwards.'
Write-Host 'This changes client capability metadata only. Verify that the gateway forwards high reasoning to Qwen.'
