[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $RepositoryRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$moduleRoot = Split-Path -Parent $PSScriptRoot
$config = Get-Content -LiteralPath (Join-Path $moduleRoot 'config.json') -Raw | ConvertFrom-Json
if ($config.enabled -isnot [bool] -or $config.context_minimization -isnot [bool]) {
    throw 'role-collaboration/config.json must contain boolean enabled and context_minimization values.'
}

$stateScript = Join-Path $moduleRoot 'scripts/get-module-state.ps1'
$temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("role-collaboration-test-" + [guid]::NewGuid().ToString('N'))
function Assert-TemporaryPath {
    param([string] $Path)
    $rootPath = [System.IO.Path]::GetFullPath($temporaryRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
    $root = $rootPath + [System.IO.Path]::DirectorySeparatorChar
    $candidate = [System.IO.Path]::GetFullPath($Path)
    if (-not ($candidate -eq $rootPath -or $candidate.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase))) {
        throw "Refusing to delete outside the temporary fixture: $candidate"
    }
}
New-Item -ItemType Directory -Path $temporaryRoot -Force | Out-Null
try {
    $cases = @(
        @{ Content = '{"enabled":true,"context_minimization":true}'; Enabled = $true; ContextMinimization = $true },
        @{ Content = '{"enabled":true,"context_minimization":false}'; Enabled = $true; ContextMinimization = $false },
        @{ Content = '{"enabled":false,"context_minimization":true}'; Enabled = $false; ContextMinimization = $false },
        @{ Content = '{"enabled":false,"context_minimization":false}'; Enabled = $false; ContextMinimization = $false },
        @{ Content = '{"enabled":"false","context_minimization":true}'; Enabled = $false; ContextMinimization = $false },
        @{ Content = '{invalid'; Enabled = $false; ContextMinimization = $false }
    )

    foreach ($case in $cases) {
        Set-Content -LiteralPath (Join-Path $temporaryRoot 'config.json') -Value $case.Content -NoNewline
        $state = & $stateScript -ModulePath $temporaryRoot
        if ($state.Enabled -ne $case.Enabled -or $state.ContextMinimization -ne $case.ContextMinimization) {
            throw "Configuration state did not match expected enabled/context values for $($case.Content)."
        }
    }

    $temporaryConfig = Join-Path $temporaryRoot 'config.json'
    Assert-TemporaryPath -Path $temporaryConfig
    Remove-Item -LiteralPath $temporaryConfig -Force
    $missingState = & $stateScript -ModulePath $temporaryRoot
    if ($missingState.Enabled -or $missingState.ContextMinimization) {
        throw 'Missing module configuration must safely disable the module.'
    }
}
finally {
    if (Test-Path -LiteralPath $temporaryRoot) {
        Assert-TemporaryPath -Path $temporaryRoot
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    }
}

$contract = Get-Content -LiteralPath (Join-Path $moduleRoot 'references/handoff-contract.md') -Raw
function Test-TemplateFields {
    param([string] $Content, [string] $Template, [string[]] $Fields)
    $pattern = '```text\r?\n' + $Template + '\r?\n(?<body>.*?)\r?\n```'
    $match = [regex]::Match($Content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $match.Success) {
        throw "Role collaboration contract has no $Template template."
    }

    foreach ($field in $Fields) {
        if ($match.Groups['body'].Value -notmatch [regex]::Escape($field)) {
            throw "$Template is missing '$field'."
        }
    }
}

$handoffFields = @('Request ID:', 'Parent request ID:', 'Depth:', 'Approved scope:', 'Requirement IDs:', 'Requested model:', 'Metadata:')
$responseFields = @('Request ID:', 'Parent request ID:', 'Status:', 'Conclusion:', 'Evidence:', 'Risks or assumptions:', 'Owner action:', 'Reported model:')
Test-TemplateFields -Content $contract -Template 'ROLE HANDOFF' -Fields $handoffFields
Test-TemplateFields -Content $contract -Template 'ROLE RESPONSE' -Fields $responseFields
foreach ($mutation in @(
        @{ Template = 'ROLE HANDOFF'; Field = 'Request ID:' },
        @{ Template = 'ROLE HANDOFF'; Field = 'Parent request ID:' },
        @{ Template = 'ROLE RESPONSE'; Field = 'Status:' }
    )) {
    $mutated = $contract -replace ([regex]::Escape($mutation.Field)), ''
    try {
        Test-TemplateFields -Content $mutated -Template $mutation.Template -Fields $(if ($mutation.Template -eq 'ROLE HANDOFF') { $handoffFields } else { $responseFields })
        throw "Mutation removing $($mutation.Field) unexpectedly passed."
    }
    catch [System.Management.Automation.RuntimeException] {
        if ($_.Exception.Message -like 'Mutation*') { throw }
    }
}

Write-Host 'Validated role-collaboration optional module.'
