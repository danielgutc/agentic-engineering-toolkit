# Toolkit validation

Run all dependency-free structural checks from the repository root:

```powershell
./tests/run.ps1
```

The suite parses PowerShell, validates canonical agents and generated Copilot profiles, checks skill metadata and installation coverage, and verifies workspace-scoped .NET artifact settings. It does not install user-level copies, invoke custom agents, verify provider model availability, or mutate consuming repositories. For agent-definition, routing, model-identifier, or synchronization changes, run the live invocation smoke described in the repository's `AGENTS.md` before pushing.
