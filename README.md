# Agentic Engineering Toolkit

Reusable Codex and GitHub Copilot agents with task-oriented skills for software engineering work.

The toolkit separates three concerns:

- Agents define who performs work, including role boundaries and permissions.
- Skills define how a repeatable engineering task is performed.
- Project repositories define what must be built and which local rules apply.

## Repository layout

```text
AGENTS.md            Repository-specific maintenance instructions
.codex/AGENTS.md     Global Codex agent-routing instructions (copied to ~/.codex/AGENTS.md)
.github/copilot-instructions.md  Global Copilot routing instructions (copied to ~/.copilot/copilot-instructions.md)
.codex/agents/       Native Codex custom-agent definitions
.github/agents/      Generated GitHub Copilot custom-agent profiles
.agents/skills/      Portable, progressively loaded skills
install/             Unified user-level copy management
tests/               Dependency-free structural validation
tools/               Agent synchronization tooling
CONTRIBUTING.md      Toolkit maintenance rules
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

The root [`AGENTS.md`](AGENTS.md) contains repository-specific maintenance instructions. The reusable [`Codex routing instructions`](.codex/AGENTS.md) and [`Copilot routing instructions`](.github/copilot-instructions.md) ask their respective coordinators to infer the appropriate custom agent from an engineering request, so the user does not need to tag an agent. The installer copies them into `~/.codex/AGENTS.md` and `~/.copilot/copilot-instructions.md`; each coordinator remains responsible for approvals between lifecycle phases. Project-specific root `AGENTS.md` files can add local constraints. Toolkit maintenance conventions are also documented in [`CONTRIBUTING.md`](CONTRIBUTING.md).

Cross-role consultation uses a coordinator-routed conversation tree. Every exchange remains 1:1, but a specialist can return `clarification_needed` to continue a short conversation with its requester or `consultation_needed` to create a nested request to another role. The coordinator routes and resumes all threads, then unwinds answers to the originating role. Chains default to two nested levels and two clarification round trips; specialists never contact each other directly or treat consultation as lifecycle approval.

Every role transition uses the shared [`role-collaboration` handoff contract](.agents/skills/role-collaboration/SKILL.md): the coordinator passes only the relevant artifact summary with approved scope, requirement IDs, prior decisions, open questions, the exact deliverable, and next owner. Specialists return conclusions, evidence, risks, and owner actions. Approval gates pause for user approval, and nested consultations preserve request and parent IDs while returning answers to the requesting role. Requested and actually reported models are recorded separately so routing and model selection can be assessed independently.

Custom agents contain reusable engineering lifecycle rules but no project-specific architecture. They inherit applicable project instructions and route repeatable work to relevant skills.

Codex TOML files are canonical for shared role instructions. Run `./tools/sync-copilot-agents.ps1` after changing them; the generated Copilot profiles preserve those instructions and reasoning effort, inherit the Copilot host's model selection, and record the canonical Codex model as metadata. Copilot role-to-model routing for newly launched agents is documented separately in `.github/copilot-instructions.md`.

## Skills

Skills are independent capabilities rather than agent personas. A skill may be used by multiple agents; for example, both the solutions architect and infrastructure engineer may use `architecture-decision`.

| Lifecycle area | Skills |
| --- | --- |
| Collaboration | `role-collaboration` |
| Orientation and workspace layout | `repository-assessment`, `implementation-workspace-layout` |
| Product and specification | `product-discovery`, `requirements-specification` |
| Domain and solution | `domain-modeling`, `solution-architecture`, `architecture-decision`, `c4-modeling` |
| Technical design and implementation | `technical-design`, `dotnet-project-structure`, `test-driven-development`, `code-review` |
| Integrated verification | `integration-e2e-testing` |
| Delivery and operations | `infrastructure-as-code`, `ci-cd-design` |

Skill entrypoints stay focused. Conditional detail, such as strategic versus tactical domain-driven design, is loaded from references only when the task needs it.

An implementation workspace is an approved unit's owned build, test, documentation, toolchain, and generated-output boundary. It can contain several language projects or packages. Repositories may have one workspace or several independent sibling workspaces, including non-code units such as customized images or database schemas. The workspace skill does not create architecture boundaries; technology-specific skills, such as `dotnet-project-structure`, refine the structure inside an already known workspace.

Codex discovers user-level skills under `~/.agents/skills` and user-level custom agents under `~/.codex/agents`.

## Install

Run the installer from PowerShell:

```powershell
./install/copy.ps1
```

The installer copies `.codex/AGENTS.md` into `~/.codex/AGENTS.md`, `.github/copilot-instructions.md` into `~/.copilot/copilot-instructions.md`, Codex agent TOML files into `~/.codex/agents`, Copilot agent profiles into `~/.copilot/agents`, and complete skill directories into `~/.agents/skills`. One copy workflow is used for every managed artifact. The script is idempotent and refuses to replace a differing destination unless `-Force` is supplied explicitly. Start a new Codex or Copilot CLI session after installation to load the user-level routing instructions.

The scripts normally resolve the current Windows profile automatically. Automation running under another account can select the intended profile explicitly:

```powershell
./install/copy.ps1 -UserHome C:\Users\danig
```

Inspect installation state without changing it:

```powershell
./install/status.ps1 -UserHome C:\Users\danig
```

Remove only unchanged copies managed by this checkout:

```powershell
./install/unlink.ps1 -UserHome C:\Users\danig
```

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
