# Toolkit validation

Run all dependency-free structural checks from the repository root:

```powershell
./tests/run.ps1
```

The suite parses PowerShell, validates canonical agents and generated Copilot profiles, checks skill metadata and installation coverage, and verifies workspace-scoped .NET artifact settings. It does not install user-level copies or mutate consuming repositories.
