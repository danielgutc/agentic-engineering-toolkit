[CmdletBinding()]
param(
    [string] $SkillRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($SkillRoot)) {
    $SkillRoot = Join-Path (Join-Path $PSScriptRoot '../..') '.agents/skills'
}
$SkillRoot = [System.IO.Path]::GetFullPath($SkillRoot)
if (-not (Test-Path -LiteralPath $SkillRoot -PathType Container)) {
    throw "Skill root does not exist: $SkillRoot"
}

$errors = [System.Collections.Generic.List[string]]::new()
$names = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$skillDirectories = @(Get-ChildItem -LiteralPath $SkillRoot -Directory)

foreach ($directory in $skillDirectories) {
    $skillPath = Join-Path $directory.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillPath -PathType Leaf)) {
        $errors.Add("Missing SKILL.md in $($directory.Name).")
        continue
    }

    if ($directory.Name -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
        $errors.Add("Skill directory '$($directory.Name)' must use safe lowercase names with letters, digits, and single hyphens.")
    }

    $content = Get-Content -LiteralPath $skillPath -Raw
    $frontMatter = [regex]::Match(
        $content,
        '\A---\r?\n(?<body>.*?)\r?\n---(?:\r?\n|\z)',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $metadata = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::Ordinal)
    if (-not $frontMatter.Success) {
        $errors.Add("$($directory.Name)/SKILL.md has no valid YAML frontmatter block; opening and closing --- lines are required.")
    }
    else {
        $metadataLines = $frontMatter.Groups['body'].Value -split '\r?\n'
        for ($lineIndex = 0; $lineIndex -lt $metadataLines.Count; $lineIndex++) {
            $line = $metadataLines[$lineIndex]
            if ([string]::IsNullOrWhiteSpace($line) -or $line -match '^\s*#') {
                continue
            }

            $fieldMatch = [regex]::Match($line, '^(?<key>[a-z][a-z0-9_-]*):(?:[ \t]+(?<value>.*)|[ \t]*)$')
            if (-not $fieldMatch.Success) {
                $requiredField = [regex]::Match($line, '^\s*(?<key>name|description)\s*:')
                if ($requiredField.Success) {
                    $errors.Add("$($directory.Name)/SKILL.md has unsupported metadata syntax for '$($requiredField.Groups['key'].Value)' on line $($lineIndex + 2); use a single-line plain scalar.")
                }
                continue
            }

            $key = $fieldMatch.Groups['key'].Value
            if ($key -notin @('name', 'description')) {
                continue
            }
            if ($metadata.ContainsKey($key)) {
                $errors.Add("$($directory.Name)/SKILL.md has duplicate metadata field '$key'.")
                continue
            }

            $value = $fieldMatch.Groups['value'].Value.Trim()
            $commentStart = [regex]::Match($value, '[ \t]+#')
            if ($commentStart.Success) {
                $value = $value.Substring(0, $commentStart.Index).TrimEnd()
            }

            if ($value -match '^(?:["''\[\]{}|>&*!]|[-?:](?:[ \t]|$))' -or $value -match ':[ \t]|\t') {
                $errors.Add("$($directory.Name)/SKILL.md uses unsupported YAML syntax for '$key' on line $($lineIndex + 2); use a single-line plain scalar.")
                continue
            }

            $metadata[$key] = $value
        }
    }

    if (-not $metadata.ContainsKey('name')) {
        $errors.Add("$($directory.Name)/SKILL.md has no name field.")
    }
    else {
        $name = $metadata['name']
        if ($name -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
            $errors.Add("Skill name '$name' must use safe lowercase names with letters, digits, and single hyphens.")
        }
        elseif ($name -cne $directory.Name) {
            $errors.Add("Skill name '$name' does not match directory '$($directory.Name)'.")
        }
        elseif (-not $names.Add($name)) {
            $errors.Add("Duplicate skill name: $name")
        }
    }

    if (-not $metadata.ContainsKey('description') -or [string]::IsNullOrWhiteSpace($metadata['description'])) {
        $errors.Add("$($directory.Name)/SKILL.md must have a nonempty description field.")
    }

    $markdownFiles = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
    $markdownFiles.Add((Get-Item -LiteralPath $skillPath))
    $referencesPath = Join-Path $directory.FullName 'references'
    if (Test-Path -LiteralPath $referencesPath -PathType Container) {
        foreach ($reference in Get-ChildItem -LiteralPath $referencesPath -Filter '*.md' -Recurse -File) {
            $markdownFiles.Add($reference)
        }
    }

    $skillFullPath = [System.IO.Path]::GetFullPath($directory.FullName)
    foreach ($markdownFile in $markdownFiles) {
        $sourceRelativePath = [System.IO.Path]::GetRelativePath($skillFullPath, $markdownFile.FullName).Replace('\', '/')
        $sourceLines = @(Get-Content -LiteralPath $markdownFile.FullName)
        for ($lineIndex = 0; $lineIndex -lt $sourceLines.Count; $lineIndex++) {
            $line = $sourceLines[$lineIndex]
            foreach ($linkStart in [regex]::Matches($line, '!?\[[^\]\r\n]*\]\(')) {
                $destinationStart = $linkStart.Index + $linkStart.Length
                $closeIndex = $line.IndexOf(')', $destinationStart)
                $location = "$($directory.Name)/$($sourceRelativePath):$($lineIndex + 1)"
                if ($closeIndex -lt 0) {
                    $errors.Add("$location has an unsupported Markdown link; use [label](destination) syntax.")
                    continue
                }

                $destination = $line.Substring($destinationStart, $closeIndex - $destinationStart).Trim()
                if ([string]::IsNullOrWhiteSpace($destination)) {
                    $errors.Add("$location has an empty Markdown link destination.")
                    continue
                }
                if ($destination -match '^(?:[a-z][a-z0-9+.-]*:|//)' -or $destination.StartsWith('#')) {
                    continue
                }
                if ($destination -match '[\s()]') {
                    $errors.Add("$location has unsupported Markdown link destination '$destination'; local destinations cannot contain whitespace or parentheses.")
                    continue
                }

                $pathEnd = $destination.IndexOfAny([char[]]@('?', '#'))
                $relativeTarget = if ($pathEnd -ge 0) { $destination.Substring(0, $pathEnd) } else { $destination }
                if ([string]::IsNullOrWhiteSpace($relativeTarget)) {
                    $errors.Add("$location has an empty local Markdown link target.")
                    continue
                }

                $relativeTarget = [System.Uri]::UnescapeDataString($relativeTarget.Replace('/', [System.IO.Path]::DirectorySeparatorChar))
                if ([System.IO.Path]::IsPathRooted($relativeTarget)) {
                    $errors.Add("$location has a rooted local Markdown link target '$destination'.")
                    continue
                }

                $resolvedTarget = [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $markdownFile.FullName) $relativeTarget))
                $withinSkill = [System.IO.Path]::GetRelativePath($skillFullPath, $resolvedTarget)
                if ($withinSkill -eq '..' -or $withinSkill.StartsWith("..$([System.IO.Path]::DirectorySeparatorChar)", [System.StringComparison]::Ordinal)) {
                    $errors.Add("$location links outside its skill directory: '$destination'.")
                    continue
                }
                if (-not (Test-Path -LiteralPath $resolvedTarget)) {
                    $errors.Add("$location links to missing local target '$destination'.")
                }
            }
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
