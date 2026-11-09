# Toolkit validation

Run all dependency-free structural checks from the repository root:

```powershell
./tests/run.ps1
```

The suite parses PowerShell, validates canonical agents and generated Copilot profiles, checks skill metadata and installation coverage, and verifies workspace-scoped .NET artifact settings. It does not install user-level copies, invoke custom agents, verify provider model availability, or mutate consuming repositories. For agent-definition, routing, model-identifier, or synchronization changes, run the live invocation smoke described in the repository's `AGENTS.md` before pushing.

Skill validation checks required metadata and local inline Markdown link targets in skill entrypoints and references. The dependency-free metadata reader supports single-line plain scalars for `name` and `description`; it does not parse optional YAML fields. Link checks resolve paths relative to the document and skip external URLs and fragment-only links. They check target existence, not fragment validity, reference-style links, or whether a skill makes good decisions.

`validate-skills-regression.ps1` exercises valid and invalid temporary skill fixtures. For routing and task behavior, use the separate manual evaluations in [skill-scenarios.md](skill-scenarios.md).
