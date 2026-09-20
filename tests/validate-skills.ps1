[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$skillRoot = Join-Path $repositoryRoot '.agents/skills'
$errors = [System.Collections.Generic.List[string]]::new()
$names = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$skillDirectories = @(Get-ChildItem -LiteralPath $skillRoot -Directory)

foreach ($directory in $skillDirectories) {
    $skillPath = Join-Path $directory.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillPath -PathType Leaf)) {
        $errors.Add("Missing SKILL.md in $($directory.Name).")
        continue
    }

    $content = Get-Content -LiteralPath $skillPath -Raw
    $frontMatter = [regex]::Match(
        $content,
        '\A---\r?\n(?<body>.*?)\r?\n---\r?\n',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    if (-not $frontMatter.Success) {
        $errors.Add("$($directory.Name)/SKILL.md has no valid YAML frontmatter block.")
        continue
    }

    $nameMatch = [regex]::Match($frontMatter.Groups['body'].Value, '(?m)^name:\s*(?<value>[^\r\n]+)\s*$')
    $descriptionMatch = [regex]::Match($frontMatter.Groups['body'].Value, '(?m)^description:\s*(?<value>[^\r\n]+)\s*$')

    if (-not $nameMatch.Success) {
        $errors.Add("$($directory.Name)/SKILL.md has no name field.")
    }
    else {
        $name = $nameMatch.Groups['value'].Value.Trim()
        if ($name -cne $directory.Name) {
            $errors.Add("Skill name '$name' does not match directory '$($directory.Name)'.")
        }

        if (-not $names.Add($name)) {
            $errors.Add("Duplicate skill name: $name")
        }
    }

    if (-not $descriptionMatch.Success) {
        $errors.Add("$($directory.Name)/SKILL.md has no description field.")
    }
    else {
        $description = $descriptionMatch.Groups['value'].Value.Trim()
        if ($description -notmatch '\bUse\b' -or $description -notmatch '\bDo not\b') {
            $errors.Add("$($directory.Name) description must state when to use and when not to use the skill.")
        }
    }
}

if ($skillDirectories.Count -eq 0) {
    $errors.Add('No skills were found.')
}

if ($errors.Count -gt 0) {
    throw "Skill validation failed:`n- $($errors -join "`n- ")"
}

Write-Host "Validated $($skillDirectories.Count) skills."
