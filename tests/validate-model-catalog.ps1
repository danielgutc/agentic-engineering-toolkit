[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$setupScript = Join-Path $repositoryRoot 'install/configure-model-catalog.ps1'
$temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('toolkit-model-catalog-' + [guid]::NewGuid().ToString('N'))

function Assert-True {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) { throw $Message }
}

function Assert-Rejected {
    param([scriptblock] $Action, [string] $Pattern)
    $rejected = $false
    try { & $Action } catch {
        if ($_.Exception.Message -notmatch $Pattern) { throw }
        $rejected = $true
    }
    Assert-True $rejected "Expected rejection matching: $Pattern"
}

try {
    $userProfile = Join-Path $temporaryRoot 'user'
    $codexRoot = Join-Path $userProfile '.codex'
    New-Item -ItemType Directory -Path $codexRoot -Force | Out-Null
    $source = Join-Path $codexRoot 'models_cache.json'
    $target = Join-Path $codexRoot 'models.toolkit.json'
    $config = Join-Path $codexRoot 'config.toml'
    $configText = "model_provider = `"custom`"`n[profiles.work]`nmodel = `"other`"`n"
    [System.IO.File]::WriteAllText($config, $configText)
    $fixture = @{
        fetched_at = 'cache metadata'
        models = @(
            @{ slug = 'other'; instructions = 'preserve'; context_window = 123456; supported_reasoning_levels = @(@{ effort = 'low'; description = 'Low' }) },
            @{ slug = 'qwen/qwen3.5-9b'; supported_reasoning_levels = @(@{ effort = 'low'; description = 'Keep this level' }); default_reasoning_level = $null; model_messages = @{ instructions_template = 'keep Qwen instructions' }; context_window = 98765 }
        )
    }
    $fixture | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $source
    $sourceBefore = [System.IO.File]::ReadAllText($source)
    & $setupScript -UserHome $userProfile -WhatIf
    Assert-True (-not (Test-Path -LiteralPath $target)) 'WhatIf created a catalog.'
    & $setupScript -UserHome $userProfile
    $generated = Get-Content -LiteralPath $target -Raw | ConvertFrom-Json
    Assert-True ($generated.models.Count -eq 2) 'An unrelated model was dropped.'
    Assert-True ($generated.models[0].context_window -eq 123456 -and $generated.models[0].instructions -eq 'preserve') 'Unrelated metadata changed.'
    $qwen = $generated.models[1]
    Assert-True ($qwen.default_reasoning_level -eq 'high') 'Qwen default is not high.'
    Assert-True (@($qwen.supported_reasoning_levels | Where-Object effort -eq 'high').Count -eq 1) 'High level missing or duplicated.'
    Assert-True (@($qwen.supported_reasoning_levels | Where-Object effort -eq 'low').Count -eq 1) 'Existing reasoning level was lost.'
    Assert-True ($qwen.context_window -eq 98765 -and $qwen.model_messages.instructions_template -eq 'keep Qwen instructions') 'Qwen metadata changed.'
    Assert-True ($generated.PSObject.Properties.Name -notcontains 'fetched_at') 'Cache envelope leaked into the catalog.'
    $first = [System.IO.File]::ReadAllText($target)
    $firstTimestamp = [System.IO.File]::GetLastWriteTimeUtc($target)
    & $setupScript -UserHome $userProfile
    Assert-True ([System.IO.File]::ReadAllText($target) -ceq $first) 'Retry changed the catalog.'
    Assert-True ([System.IO.File]::GetLastWriteTimeUtc($target) -eq $firstTimestamp) 'Retry rewrote an unchanged catalog.'
    Assert-True ([System.IO.File]::ReadAllText($config) -ceq $configText) 'Personal config was modified.'
    Assert-True ([System.IO.File]::ReadAllText($source) -ceq $sourceBefore) 'Source cache was modified.'
    [System.IO.File]::WriteAllText($target, '{"personal":true}')
    Assert-Rejected { & $setupScript -UserHome $userProfile } 'differs.*Force'
    & $setupScript -UserHome $userProfile -Force -WhatIf
    Assert-True ([System.IO.File]::ReadAllText($target) -ceq '{"personal":true}') 'WhatIf replaced a differing catalog.'
    & $setupScript -UserHome $userProfile -Force
    Assert-True ([System.IO.File]::ReadAllText($target) -ceq $first) 'Forced regeneration failed.'
    Assert-Rejected { & $setupScript -UserHome $userProfile -SourceCatalog $target -Force } 'source.*destination'
    $fixture.models = @($fixture.models[0])
    $fixture | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $source
    Assert-Rejected { & $setupScript -UserHome $userProfile -Force } 'exactly one.*qwen'
    Assert-True ([System.IO.File]::ReadAllText($target) -ceq $first) 'Invalid input changed the output.'
    $fixture.models = @($qwen, $qwen)
    $fixture | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $source
    Assert-Rejected { & $setupScript -UserHome $userProfile -Force } 'exactly one.*qwen'
    [System.IO.File]::WriteAllText($source, '{"models":[]}')
    Assert-Rejected { & $setupScript -UserHome $userProfile -Force } 'nonempty models array'
    [System.IO.File]::WriteAllText($source, '{bad json')
    Assert-Rejected { & $setupScript -UserHome $userProfile -Force } 'JSON'
    Assert-Rejected { & $setupScript -UserHome (Join-Path $temporaryRoot 'absent') } 'Source catalog.*not found'
    $qwen.supported_reasoning_levels = @()
    $qwen.default_reasoning_level = $null
    $fixture.models = @($qwen)
    $explicitSource = Join-Path $temporaryRoot 'selected-catalog.json'
    $fixture | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $explicitSource
    & $setupScript -UserHome (Join-Path $temporaryRoot 'fresh') -SourceCatalog $explicitSource -WhatIf
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $temporaryRoot 'fresh'))) 'WhatIf created a profile directory.'
    & $setupScript -UserHome (Join-Path $temporaryRoot 'fresh') -SourceCatalog $explicitSource
    Assert-True (Test-Path -LiteralPath (Join-Path $temporaryRoot 'fresh/.codex/models.toolkit.json')) 'Explicit catalog setup failed.'
    $emptyLevelsResult = Get-Content (Join-Path $temporaryRoot 'fresh/.codex/models.toolkit.json') -Raw | ConvertFrom-Json
    Assert-True ($emptyLevelsResult.models[0].supported_reasoning_levels.Count -eq 1 -and $emptyLevelsResult.models[0].supported_reasoning_levels[0].effort -eq 'high') 'Empty reasoning levels were not repaired.'
    $blockedProfile = Join-Path $temporaryRoot 'blocked'
    New-Item -ItemType Directory -Path (Join-Path $blockedProfile '.codex/models.toolkit.json') -Force | Out-Null
    Assert-Rejected { & $setupScript -UserHome $blockedProfile -SourceCatalog $explicitSource -Force } 'regular file'
}
finally {
    $resolved = [System.IO.Path]::GetFullPath($temporaryRoot)
    $tempPrefix = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $resolved.StartsWith($tempPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
        [System.IO.Path]::GetFileName($resolved) -notlike 'toolkit-model-catalog-*') {
        throw "Unsafe fixture cleanup path: $resolved"
    }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
Write-Host 'Validated model catalog generation, preservation, retries, conflicts, invalid inputs and WhatIf.'
