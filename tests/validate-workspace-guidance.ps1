[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$assetRoot = Join-Path $repositoryRoot '.agents/skills/dotnet-project-structure/assets'
$propsPath = Join-Path $assetRoot 'Directory.Build.props'
$ignorePath = Join-Path $assetRoot 'gitignore.fragment'

[xml] $props = Get-Content -LiteralPath $propsPath -Raw
$propertyGroups = @($props.Project.PropertyGroup)
$useArtifactsOutput = @($propertyGroups.UseArtifactsOutput | Where-Object { $_ })
$artifactsPaths = @($propertyGroups.ArtifactsPath | Where-Object { $_ })
$expectedArtifactsPath = '$(MSBuildThisFileDirectory)artifacts'
$errors = [System.Collections.Generic.List[string]]::new()

if ($useArtifactsOutput.Count -ne 1 -or [string] $useArtifactsOutput[0] -cne 'true') {
    $errors.Add('Directory.Build.props must enable UseArtifactsOutput exactly once.')
}

if ($artifactsPaths.Count -ne 1 -or [string] $artifactsPaths[0] -cne $expectedArtifactsPath) {
    $errors.Add("Directory.Build.props must anchor ArtifactsPath to '$expectedArtifactsPath'.")
}

$ignoreRules = @(
    Get-Content -LiteralPath $ignorePath |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith('#') }
)
if ($ignoreRules.Count -ne 1 -or $ignoreRules[0] -cne '/artifacts/') {
    $errors.Add('The workspace-local gitignore fragment must contain only the anchored /artifacts/ rule.')
}

if ($errors.Count -gt 0) {
    throw "Workspace guidance validation failed:`n- $($errors -join "`n- ")"
}

Write-Host 'Validated workspace-scoped .NET artifact guidance.'
