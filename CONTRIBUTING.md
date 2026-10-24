# Toolkit Maintenance

## Purpose

- Maintain this repository as a reusable, project-neutral Codex and GitHub Copilot toolkit.
- Keep agent roles separate from task-oriented skills.
- Encode reusable blueprint principles while keeping project-specific lifecycle rules and architecture in each consuming repository.

## Repository model

- Store native Codex agents in `.codex/agents/`.
- Store reusable Codex agent-routing instructions in `.codex/AGENTS.md`.
- Store reusable Copilot CLI agent-routing instructions in `.github/copilot-instructions.md`.
- Store repository-specific maintenance instructions in the root `AGENTS.md`.
- Store generated GitHub Copilot agent clones in `.github/agents/`.
- Store portable skills in `.agents/skills/<skill-name>/SKILL.md`.
- Store user-level copy management in `install/`.
- Store structural validation in `tests/`.

## Agent rules

- Give each agent one standard engineering role with explicit boundaries.
- Treat `.codex/agents/*.toml` as the canonical agent definitions and `.github/agents/*.agent.md` as generated Copilot clones.
- Keep Copilot-only model overrides in Copilot synchronization tooling; do not add Copilot settings to canonical Codex agent definitions.
- Keep every Codex and Copilot agent synchronized. After changing a canonical agent, run `./tools/sync-copilot-agents.ps1` and commit both formats together.
- Never edit a generated Copilot agent directly; update its canonical Codex TOML and regenerate it.
- Maintain the canonical flow from product owner to solutions architect, technical architect, software and infrastructure engineers, and test engineer.
- Preserve abstraction levels and artifact ownership; return scope changes to the role that owns the affected decision.
- Use Sol for product and architecture reasoning, Terra for implementation and infrastructure, and Luna for bounded integrated-system verification.
- Apply specification-driven development, C4, DDD, TDD, DevOps, and evolutive architecture only in the roles and lifecycle stages where they belong.
- Keep agent instructions concise and independent of a specific repository or technology stack.
- Grant workspace write access only because each canonical role owns enduring artifacts, implementation, infrastructure, or tests; instructions must still constrain what it may change.
- Route agents only to skills that exist in this repository.
- Require concise handoffs containing conclusions, evidence, validation, and unresolved risks.
- Keep the shared `role-collaboration` handoff contract synchronized with both coordinator routing files; handoffs must carry approved scope, requirement IDs, decisions, open questions, deliverable, next owner, and separate requested/reported model fields.

## Skill rules

- Model a skill as a reusable procedure, not a persona.
- Give each skill a narrow trigger description and a self-contained workflow.
- Align skills with lifecycle outcomes and abstraction levels rather than duplicating an agent's full role.
- Keep shared entrypoints compact and load strategic, tactical, or technology-specific references only when needed.
- Put optional detail in `references/`, reusable output material in `assets/`, and automation in `scripts/`.
- Do not duplicate project templates or project-specific instructions in global skills.

## Installation rules

- Install agents, skills, and routing instructions as regular files and directories copied into their user-level locations.
- Copy `.codex/AGENTS.md` to `~/.codex/AGENTS.md`; keep repository maintenance guidance in the root `AGENTS.md` and out of the user-level installation.
- Copy `.github/copilot-instructions.md` to `~/.copilot/copilot-instructions.md` for user-level Copilot CLI routing; keep repository maintenance guidance out of it.
- Never replace a differing managed copy unless the caller explicitly uses `-Force`.
- Never replace or delete an unrelated target.
- Keep personal instruction files outside this repository.

## Verification

- Run `./tests/run.ps1` after changing agents, skills, synchronization tooling, or the installation manifest.
- Keep validation dependency-free and compatible with PowerShell 7.
- Extend `tests/validate-handoff-contract.ps1` when changing shared handoff or coordinator-routing requirements.
