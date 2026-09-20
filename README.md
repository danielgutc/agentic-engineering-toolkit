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

| Agent | Primary responsibility | Default access |
| --- | --- | --- |
| `architect` | Architecture, boundaries, tradeoffs, and technical decisions | Read-only |
| `developer` | Approved implementation and developer-level tests | Workspace write |
| `tester` | Test design, independent verification, and regression analysis | Workspace write |
| `infrastructure_engineer` | Build, deployment, environments, observability, and infrastructure | Workspace write |

Custom agents intentionally contain no project-specific architecture or lifecycle rules. They inherit applicable project instructions and use relevant skills when a task calls for them.

## Skills

Skills are independent capabilities rather than agent personas. A skill may be used by multiple agents; for example, both an architect and infrastructure engineer may use `architecture-decision`.

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
