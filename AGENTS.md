# Repository Instructions

This repository is a project-neutral toolkit of Codex and GitHub Copilot agents and skills. Keep reusable role guidance in `.codex/agents/`, portable procedures in `.agents/skills/`, and repository-specific maintenance guidance here.

## Agent and skill changes

- Treat `.codex/agents/*.toml` as canonical; do not edit generated `.github/agents/*.agent.md` files directly.
- After changing a Codex agent TOML, run `./scripts/maintenance/sync-copilot-agents.ps1` to regenerate Copilot profiles.
- Keep agent and skill references valid, and avoid adding project-specific rules to reusable agent or skill definitions.
- Update `README.md` for user-facing behavior and `CONTRIBUTING.md` for toolkit maintenance conventions.

## Scripts and validation

- Run `./scripts/tests/run.ps1` after changes to agents, skills, synchronization tooling, PowerShell scripts, or the installation manifest.
- Before pushing a branch that changes agent definitions, routing, model identifiers, or agent synchronization tooling, invoke every affected custom agent through the live Codex runtime with a minimal smoke task. Verify that each launch returns successfully and that its configured model and reasoning effort match the canonical TOML; test every role that shares a changed model identifier.
- Include the invocation results in the PR description. Do not push if an affected agent fails to launch. The structural test suite does not replace this runtime check.
- Use `./scripts/install/status.ps1` to inspect the user-level installation without changing it.
- Use `./scripts/install/copy.ps1` to install or update the managed agents, skills, and Codex routing instructions. A differing destination is not replaced unless `-Force` is explicitly supplied.
- Use `./scripts/install/unlink.ps1` to remove only unchanged copies managed by this checkout.
- Installation scripts accept `-UserHome` to target a specific profile.

## Instruction-file scopes

- This root `AGENTS.md` contains maintenance rules for this repository.
- `.codex/AGENTS.md` contains reusable Codex agent-routing instructions and is copied to `~/.codex/AGENTS.md` by the installer.
