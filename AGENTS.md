# Agent Instructions

## Purpose

- Maintain this repository as a reusable, project-neutral Codex toolkit.
- Keep agent roles separate from task-oriented skills.
- Keep project and blueprint lifecycle rules out of this repository.

## Repository model

- Store native Codex agents in `.codex/agents/`.
- Store portable skills in `.agents/skills/<skill-name>/SKILL.md`.
- Store symlink management in `install/`.
- Store structural validation in `tests/`.

## Agent rules

- Give each agent one standard engineering role with explicit boundaries.
- Keep agent instructions concise and independent of a specific repository or technology stack.
- Use read-only access unless the role requires edits.
- Require concise handoffs containing conclusions, evidence, validation, and unresolved risks.

## Skill rules

- Model a skill as a reusable procedure, not a persona.
- Give each skill a narrow trigger description and a self-contained workflow.
- Put optional detail in `references/`, reusable output material in `assets/`, and automation in `scripts/`.
- Do not duplicate project templates or project-specific instructions in global skills.

## Installation rules

- Install agents and skills using individual symbolic links.
- Never replace or delete an existing non-link target.
- Never copy managed artifacts as an installation fallback.
- Keep personal instruction files outside this repository.

## Verification

- Run `./tests/run.ps1` after changing agents, skills, or the link manifest.
- Keep validation dependency-free and compatible with PowerShell 7.
