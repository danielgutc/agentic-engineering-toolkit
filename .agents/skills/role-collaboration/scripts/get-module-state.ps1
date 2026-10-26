[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $ModulePath
)

Set-StrictMode -Version Latest
$configPath = Join-Path $ModulePath 'config.json'
$disabled = [PSCustomObject]@{ Enabled = $false; ContextMinimization = $false; Reason = 'missing-or-invalid-config' }
if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    return $disabled
}

try {
    $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    if ($config.enabled -isnot [bool] -or $config.context_minimization -isnot [bool]) {
        return $disabled
    }

    return [PSCustomObject]@{
        Enabled = $config.enabled
        ContextMinimization = ($config.enabled -and $config.context_minimization)
        Reason = if ($config.enabled) { 'configured' } else { 'disabled' }
    }
}
catch {
    return $disabled
}
