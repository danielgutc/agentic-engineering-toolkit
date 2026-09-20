# Agent Instructions

## Purpose

- Maintain this repository as a reusable, project-neutral Codex toolkit.
- Keep agent roles separate from task-oriented skills.
- Encode reusable blueprint principles while keeping project-specific lifecycle rules and architecture in each consuming repository.

## Repository model

- Store native Codex agents in `.codex/agents/`.
- Store portable skills in `.agents/skills/<skill-name>/SKILL.md`.
- Store symlink management in `install/`.
- Store structural validation in `tests/`.

## Agent rules

- Give each agent one standard engineering role with explicit boundaries.
- Maintain the canonical flow from product owner to solutions architect, technical architect, software and infrastructure engineers, and test engineer.
- Preserve abstraction levels and artifact ownership; return scope changes to the role that owns the affected decision.
- Use Sol for product and architecture reasoning, Terra for implementation and infrastructure, and Luna for bounded integrated-system verification.
- Apply specification-driven development, C4, DDD, TDD, DevOps, and evolutive architecture only in the roles and lifecycle stages where they belong.
- Keep agent instructions concise and independent of a specific repository or technology stack.
- Grant workspace write access only because each canonical role owns enduring artifacts, implementation, infrastructure, or tests; instructions must still constrain what it may change.
- Route agents only to skills that exist in this repository.
- Require concise handoffs containing conclusions, evidence, validation, and unresolved risks.

## Skill rules

- Model a skill as a reusable procedure, not a persona.
- Give each skill a narrow trigger description and a self-contained workflow.
- Align skills with lifecycle outcomes and abstraction levels rather than duplicating an agent's full role.
- Keep shared entrypoints compact and load strategic, tactical, or technology-specific references only when needed.
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
