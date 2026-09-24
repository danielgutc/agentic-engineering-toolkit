[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$agentDirectory = Join-Path $repositoryRoot '.codex/agents'
$expectedAgents = [ordered]@{
    'product-owner.toml' = @{
        Name = 'product_owner'
        Model = 'gpt-5.6-sol'
        ReasoningEffort = 'medium'
        Sandbox = 'workspace-write'
        Skills = @('role-collaboration', 'repository-assessment', 'product-discovery', 'requirements-specification', 'domain-modeling')
    }
    'solutions-architect.toml' = @{
        Name = 'solutions_architect'
        Model = 'gpt-5.6-sol'
        ReasoningEffort = 'high'
        Sandbox = 'workspace-write'
        Skills = @('role-collaboration', 'repository-assessment', 'solution-architecture', 'domain-modeling', 'architecture-decision', 'c4-modeling')
    }
    'technical-architect.toml' = @{
        Name = 'technical_architect'
        Model = 'gpt-5.6-sol'
        ReasoningEffort = 'high'
        Sandbox = 'workspace-write'
        Skills = @('role-collaboration', 'repository-assessment', 'technical-design', 'domain-modeling', 'architecture-decision', 'c4-modeling', 'test-driven-development')
    }
    'software-engineer.toml' = @{
        Name = 'software_engineer'
        Model = 'gpt-5.6-terra'
        ReasoningEffort = 'medium'
        Sandbox = 'workspace-write'
        Skills = @('role-collaboration', 'repository-assessment', 'test-driven-development', 'code-review')
    }
    'infrastructure-engineer.toml' = @{
        Name = 'infrastructure_engineer'
        Model = 'gpt-5.6-terra'
        ReasoningEffort = 'high'
        Sandbox = 'workspace-write'
        Skills = @('role-collaboration', 'repository-assessment', 'architecture-decision', 'infrastructure-as-code', 'ci-cd-design')
    }
    'test-engineer.toml' = @{
        Name = 'test_engineer'
        Model = 'gpt-5.6-luna'
        ReasoningEffort = 'medium'
        Sandbox = 'workspace-write'
        Skills = @('role-collaboration', 'repository-assessment', 'integration-e2e-testing', 'code-review')
    }
}

$errors = [System.Collections.Generic.List[string]]::new()
$actualFiles = @(Get-ChildItem -LiteralPath $agentDirectory -File -Filter '*.toml')
$skillDirectory = Join-Path $repositoryRoot '.agents/skills'
$knownSkills = @(Get-ChildItem -LiteralPath $skillDirectory -Directory | Select-Object -ExpandProperty Name)

foreach ($file in $actualFiles) {
    if (-not $expectedAgents.Contains($file.Name)) {
        $errors.Add("Unexpected agent file: $($file.Name)")
    }
}

foreach ($entry in $expectedAgents.GetEnumerator()) {
    $path = Join-Path $agentDirectory $entry.Key
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $errors.Add("Missing agent file: $($entry.Key)")
        continue
    }

    $content = Get-Content -LiteralPath $path -Raw
    $expectedName = [regex]::Escape($entry.Value.Name)
    $expectedModel = [regex]::Escape($entry.Value.Model)
    $expectedReasoningEffort = [regex]::Escape($entry.Value.ReasoningEffort)
    $expectedSandbox = [regex]::Escape($entry.Value.Sandbox)

    if ($content -notmatch "(?m)^name\s*=\s*`"$expectedName`"\s*$") {
        $errors.Add("$($entry.Key) does not define the expected name '$($entry.Value.Name)'.")
    }

    if ($content -notmatch '(?m)^description\s*=\s*".+"\s*$') {
        $errors.Add("$($entry.Key) does not define a description.")
    }

    if ($content -notmatch "(?m)^model\s*=\s*`"$expectedModel`"\s*$") {
        $errors.Add("$($entry.Key) does not define model '$($entry.Value.Model)'.")
    }

    if ($content -notmatch "(?m)^model_reasoning_effort\s*=\s*`"$expectedReasoningEffort`"\s*$") {
        $errors.Add("$($entry.Key) does not define reasoning effort '$($entry.Value.ReasoningEffort)'.")
    }

    if ($content -notmatch "(?m)^sandbox_mode\s*=\s*`"$expectedSandbox`"\s*$") {
        $errors.Add("$($entry.Key) does not define sandbox mode '$($entry.Value.Sandbox)'.")
    }

    if ($content -notmatch '(?m)^developer_instructions\s*=\s*"""\s*$') {
        $errors.Add("$($entry.Key) does not define multiline developer instructions.")
    }

    foreach ($skill in $entry.Value.Skills) {
        $skillReference = [regex]::Escape('$' + $skill)
        if ($content -notmatch $skillReference) {
            $errors.Add("$($entry.Key) does not route applicable work to `$$skill.")
        }
    }

    foreach ($match in [regex]::Matches($content, '\$(?<name>[a-z0-9-]+)')) {
        $referencedSkill = $match.Groups['name'].Value
        if ($knownSkills -notcontains $referencedSkill) {
            $errors.Add("$($entry.Key) references missing skill '$referencedSkill'.")
        }
    }
}

if ($errors.Count -gt 0) {
    throw "Agent validation failed:`n- $($errors -join "`n- ")"
}

Write-Host "Validated $($expectedAgents.Count) Codex agents."
