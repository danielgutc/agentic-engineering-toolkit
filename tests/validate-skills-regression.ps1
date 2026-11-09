[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$validatorPath = Join-Path $PSScriptRoot 'validate-skills.ps1'
$temporaryDirectory = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$temporaryPrefix = $temporaryDirectory.TrimEnd([char[]]@('\', '/')) + [System.IO.Path]::DirectorySeparatorChar
$fixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $temporaryDirectory "validate-skills-$([guid]::NewGuid().ToString('N'))"))
if (-not $fixtureRoot.StartsWith($temporaryPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
    -not [System.IO.Path]::GetFileName($fixtureRoot).StartsWith('validate-skills-', [System.StringComparison]::Ordinal)) {
    throw "Unsafe fixture root: $fixtureRoot"
}
New-Item -ItemType Directory -Path $fixtureRoot | Out-Null

function New-SkillFixture {
    param(
        [Parameter(Mandatory)] [string] $Root,
        [Parameter(Mandatory)] [string] $DirectoryName,
        [Parameter(Mandatory)] [string] $Metadata,
        [string] $Body = ''
    )

    $directory = Join-Path $Root $DirectoryName
    New-Item -ItemType Directory -Path $directory | Out-Null
    Set-Content -LiteralPath (Join-Path $directory 'SKILL.md') -Value "$Metadata`n$Body" -NoNewline
    return $directory
}

function Invoke-SkillValidator {
    param([Parameter(Mandatory)] [string] $Root)

    try {
        $output = @(& $validatorPath -SkillRoot $Root 2>&1 | ForEach-Object { $_.ToString() })
        return [pscustomobject]@{ Succeeded = $true; Output = $output -join "`n" }
    }
    catch {
        return [pscustomobject]@{ Succeeded = $false; Output = $_.Exception.Message }
    }
}

function Assert-ValidatorSuccess {
    param([string] $Label, [string] $Root)

    $result = Invoke-SkillValidator -Root $Root
    if (-not $result.Succeeded) {
        throw "$Label should pass validation, but failed: $($result.Output)"
    }
}

function Assert-ValidatorFailure {
    param([string] $Label, [string] $Root, [string] $ExpectedText)

    $result = Invoke-SkillValidator -Root $Root
    if ($result.Succeeded) {
        throw "$Label should fail validation."
    }
    if ($result.Output -notlike "*$ExpectedText*") {
        throw "$Label failed without the expected diagnostic '$ExpectedText': $($result.Output)"
    }
}

try {
    $validRoot = Join-Path $fixtureRoot 'valid'
    New-Item -ItemType Directory -Path $validRoot | Out-Null
    $validSkill = New-SkillFixture -Root $validRoot -DirectoryName 'phrase-free-skill' -Metadata @'
---
name: phrase-free-skill
description: Map repository structure and identify useful entry points.
metadata:
  source: toolkit
---
'@ -Body @'
Read [the guide](references/guide.md#intro), [its example](references/example.md), [the external site](https://example.com/docs), and [this section](#details).
'@
    $references = Join-Path $validSkill 'references'
    New-Item -ItemType Directory -Path $references | Out-Null
    Set-Content -LiteralPath (Join-Path $references 'guide.md') -Value '[Example](example.md)' -NoNewline
    Set-Content -LiteralPath (Join-Path $references 'example.md') -Value 'Fixture reference.' -NoNewline
    Assert-ValidatorSuccess -Label 'Phrase-free description and supported links' -Root $validRoot

    $brokenRoot = Join-Path $fixtureRoot 'broken-link'
    New-Item -ItemType Directory -Path $brokenRoot | Out-Null
    New-SkillFixture -Root $brokenRoot -DirectoryName 'broken-link-skill' -Metadata @'
---
name: broken-link-skill
description: Describe a useful workflow.
---
'@ -Body 'Read [the missing guide](references/missing.md).'
    Assert-ValidatorFailure -Label 'Missing local Markdown target' -Root $brokenRoot -ExpectedText 'references/missing.md'

    $brokenReferenceRoot = Join-Path $fixtureRoot 'broken-reference-link'
    New-Item -ItemType Directory -Path $brokenReferenceRoot | Out-Null
    $brokenReferenceSkill = New-SkillFixture -Root $brokenReferenceRoot -DirectoryName 'broken-reference-skill' -Metadata @'
---
name: broken-reference-skill
description: Describe a useful workflow.
---
'@ -Body 'Read [the guide](references/guide.md).'
    $brokenReferenceDirectory = Join-Path $brokenReferenceSkill 'references'
    New-Item -ItemType Directory -Path $brokenReferenceDirectory | Out-Null
    Set-Content -LiteralPath (Join-Path $brokenReferenceDirectory 'guide.md') -Value '[the missing page](missing.md)' -NoNewline
    Assert-ValidatorFailure -Label 'Missing target in a reference document' -Root $brokenReferenceRoot -ExpectedText 'missing.md'

    $malformedRoot = Join-Path $fixtureRoot 'malformed-metadata'
    New-Item -ItemType Directory -Path $malformedRoot | Out-Null
    New-SkillFixture -Root $malformedRoot -DirectoryName 'malformed-skill' -Metadata @'
---
name: malformed-skill
name: another-name
description: Describe a useful workflow.
---
'@
    Assert-ValidatorFailure -Label 'Duplicate metadata field' -Root $malformedRoot -ExpectedText 'duplicate metadata field'

    $unsafeNameRoot = Join-Path $fixtureRoot 'unsafe-name'
    New-Item -ItemType Directory -Path $unsafeNameRoot | Out-Null
    New-SkillFixture -Root $unsafeNameRoot -DirectoryName 'unsafe_name' -Metadata @'
---
name: unsafe_name
description: Describe a useful workflow.
---
'@
    Assert-ValidatorFailure -Label 'Unsafe skill name' -Root $unsafeNameRoot -ExpectedText 'safe lowercase'

    $emptyDescriptionRoot = Join-Path $fixtureRoot 'empty-description'
    New-Item -ItemType Directory -Path $emptyDescriptionRoot | Out-Null
    New-SkillFixture -Root $emptyDescriptionRoot -DirectoryName 'empty-description-skill' -Metadata @'
---
name: empty-description-skill
description:
---
'@
    Assert-ValidatorFailure -Label 'Empty description' -Root $emptyDescriptionRoot -ExpectedText 'nonempty description'

    Write-Host 'Skill validator regression checks passed.'
}
finally {
    $resolvedFixtureRoot = [System.IO.Path]::GetFullPath($fixtureRoot)
    if (-not $resolvedFixtureRoot.StartsWith($temporaryPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not [System.IO.Path]::GetFileName($resolvedFixtureRoot).StartsWith('validate-skills-', [System.StringComparison]::Ordinal)) {
        throw "Refusing to remove unsafe fixture root: $resolvedFixtureRoot"
    }
    Remove-Item -LiteralPath $fixtureRoot -Recurse -Force
}
