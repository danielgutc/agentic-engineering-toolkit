[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$scriptFiles = @(
    Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'install') -File -Filter '*.ps1'
    Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'tests') -File -Filter '*.ps1'
)
$errors = [System.Collections.Generic.List[string]]::new()

foreach ($file in $scriptFiles) {
    $tokens = $null
    $parseErrors = $null
    [void] [System.Management.Automation.Language.Parser]::ParseFile(
        $file.FullName,
        [ref] $tokens,
        [ref] $parseErrors
    )

    foreach ($parseError in $parseErrors) {
        $errors.Add("$($file.Name):$($parseError.Extent.StartLineNumber): $($parseError.Message)")
    }
}

if ($errors.Count -gt 0) {
    throw "PowerShell parsing failed:`n- $($errors -join "`n- ")"
}

Write-Host "Parsed $($scriptFiles.Count) PowerShell scripts."
