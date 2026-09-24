[CmdletBinding()]
param(
    [string] $UserHome
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'common.ps1')

$results = foreach ($link in Get-ToolkitLinks -InstallDirectory $PSScriptRoot -UserHome $UserHome) {
    [PSCustomObject]@{
        Name = $link.Name
        State = Get-ToolkitCopyState -Link $link
        Target = $link.Target
        Source = $link.Source
    }
}

$results | Format-Table -AutoSize

if ($results.State -contains 'Conflict' -or $results.State -contains 'WrongTarget' -or $results.State -contains 'MissingSource' -or $results.State -contains 'LinkedSourceMissing' -or $results.State -contains 'Outdated') {
    exit 1
}
