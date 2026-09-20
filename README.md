# Agentic Engineering Toolkit

Reusable Codex agents and task-oriented skills for software engineering work.

The toolkit separates three concerns:

- Agents define who performs work, including role boundaries and permissions.
- Skills define how a repeatable engineering task is performed.
- Project repositories define what must be built and which local rules apply.

## Repository layout

```text
.codex/agents/       Native Codex custom-agent definitions
.agents/skills/      Portable, progressively loaded skills
install/             Symlink management for user-level installation
tests/               Dependency-free structural validation
```

## Agents

| Agent | Model | Primary responsibility | Default access |
| --- | --- | --- | --- |
| `product_owner` | `gpt-5.6-sol` (medium) | Product outcomes, MVP scope, UX intent, and testable requirements | Workspace write |
| `solutions_architect` | `gpt-5.6-sol` (high) | System boundaries, domain architecture, C4 context and containers, and solution tradeoffs | Workspace write |
| `technical_architect` | `gpt-5.6-sol` (high) | Container internals, components, interfaces, skeletons, test strategy, and engineering toolsets | Workspace write |
| `software_engineer` | `gpt-5.6-terra` (medium) | TDD implementation of approved behavior and developer-level tests | Workspace write |
| `infrastructure_engineer` | `gpt-5.6-terra` (high) | DevOps, build, delivery, environments, observability, and infrastructure as code | Workspace write |
| `test_engineer` | `gpt-5.6-luna` (medium) | Independent integration, contract, end-to-end, acceptance, and regression verification | Workspace write |

The default ownership flow is `product_owner -> solutions_architect -> technical_architect -> software_engineer/infrastructure_engineer -> test_engineer`. Each role stays at its assigned abstraction level, follows project approval gates, and returns consequential changes to the appropriate owner rather than silently widening scope.

Custom agents contain reusable engineering lifecycle rules but no project-specific architecture. They inherit applicable project instructions and route repeatable work to relevant skills.

## Skills

Skills are independent capabilities rather than agent personas. A skill may be used by multiple agents; for example, both the solutions architect and infrastructure engineer may use `architecture-decision`.

| Lifecycle area | Skills |
| --- | --- |
| Orientation | `repository-assessment` |
| Product and specification | `product-discovery`, `requirements-specification` |
| Domain and solution | `domain-modeling`, `solution-architecture`, `architecture-decision`, `c4-modeling` |
| Technical design and implementation | `technical-design`, `test-driven-development`, `code-review` |
| Integrated verification | `integration-e2e-testing` |
| Delivery and operations | `infrastructure-as-code`, `ci-cd-design` |

Skill entrypoints stay focused. Conditional detail, such as strategic versus tactical domain-driven design, is loaded from references only when the task needs it.

Codex discovers user-level skills under `~/.agents/skills` and user-level custom agents under `~/.codex/agents`.

## Install

Run the installer from PowerShell:

```powershell
./install/link.ps1
```

The installer creates individual symbolic links from the user-level Codex locations to this checkout. It never copies files and never replaces an existing file or directory.

The scripts normally resolve the current Windows profile automatically. Automation running under another account can select the intended profile explicitly:

```powershell
./install/link.ps1 -UserHome C:\Users\danig
```

Inspect installation state without changing it:

```powershell
./install/status.ps1 -UserHome C:\Users\danig
```

Remove only links managed by this checkout:

```powershell
./install/unlink.ps1 -UserHome C:\Users\danig
```

Windows may require Developer Mode or an elevated shell to create symbolic links.

## Validate

```powershell
./tests/run.ps1
```

The checks validate agent fields, skill metadata, and the installation manifest without requiring third-party modules.

## Delegation guidance

Multi-agent execution is useful for independent work, context isolation, and role-specific verification. It is not a default optimization for total token usage because each agent receives its own context.

- Keep sequential decisions in one thread.
- Delegate only bounded work with a clear return contract.
- Reuse evidence gathered by another agent instead of repeating repository scans.
- Prefer one specialist over several overlapping specialists.
- Ask agents to return concise conclusions, evidence, and unresolved decisions.
