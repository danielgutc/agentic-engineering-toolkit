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
| `software_engineer` | `qwen/qwen3.5-9b` (high) | TDD implementation of approved behavior and developer-level tests | Workspace write |
| `infrastructure_engineer` | `gpt-5.6-terra` (high) | DevOps, build, delivery, environments, observability, and infrastructure as code | Workspace write |
| `test_engineer` | `qwen/qwen3.5-9b` (high) | Independent integration, contract, end-to-end, acceptance, and regression verification | Workspace write |

The default ownership flow is `product_owner -> solutions_architect -> technical_architect -> software_engineer/infrastructure_engineer -> test_engineer`. Each role stays at its assigned abstraction level, follows project approval gates, and returns consequential changes to the appropriate owner rather than silently widening scope.

The root [`AGENTS.md`](AGENTS.md) contains repository-specific maintenance instructions. The reusable [`Codex routing instructions`](.codex/AGENTS.md) and [`Copilot routing instructions`](.github/copilot-instructions.md) ask their respective coordinators to infer the appropriate custom agent from an engineering request, so the user does not need to tag an agent. The installer copies them into `~/.codex/AGENTS.md` and `~/.copilot/copilot-instructions.md`; each coordinator remains responsible for approvals between lifecycle phases. Project-specific root `AGENTS.md` files can add local constraints. Toolkit maintenance conventions are also documented in [`CONTRIBUTING.md`](CONTRIBUTING.md).

Coordinator routing, role ownership, and user approval gates are always active. The optional [`role-collaboration`](.agents/skills/role-collaboration/SKILL.md) module adds the structured handoff protocol and, independently, a context-minimization policy. Its module-local `config.json` enables both by default; set `enabled` to `false` to use the generic fallback, or set only `context_minimization` to `false` to retain the protocol without isolated-context guidance. Invalid or missing configuration safely uses the fallback.

Custom agents contain reusable engineering lifecycle rules but no project-specific architecture. They inherit applicable project instructions and route repeatable work to relevant skills.

Codex TOML files are canonical for shared role instructions. Run `./tools/sync-copilot-agents.ps1` after changing them; the generated Copilot profiles preserve those instructions and reasoning effort, inherit the Copilot host's model selection, and record the canonical Codex model as metadata. Copilot role-to-model routing for newly launched agents is documented separately in `.github/copilot-instructions.md`.

## MVP rationale ownership

The product owner records why the MVP is the smallest useful release, its users, scope, quality outcomes, and acceptance intent. The solutions architect justifies the chosen architecture against those inputs and known next capabilities. The technical architect records how components, contracts, dependencies, and test seams realize the approved direction.

Those decisions and their evidence belong in consuming project artifacts. Global Codex/Copilot coordinator instructions provide routing and approval behavior; implementation, delivery, and verification roles follow approved project contracts. The toolkit does not impose a universal MVP version label or architectural policy.

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

Disable the optional collaboration framework in an installed toolkit by editing `~/.agents/skills/role-collaboration/config.json` (or edit the source `.agents/skills/role-collaboration/config.json` before a future install):

```json
{ "enabled": false, "context_minimization": false }
```

Remove only its unchanged installed copy with explicit feature selection:

```powershell
./install/unlink.ps1 -UserHome C:\Users\danig -Feature role-collaboration
```

Use `unlink.ps1 ... -Feature role-collaboration -Force` only for a modified or source-orphaned installed copy. Deleting the source module does not remove its installed copy; it is reported as orphaned until targeted removal. In contrast, `copy.ps1 -Force` refreshes from the source and can reset locally edited `config.json` settings. Do not run install scripts against a real profile merely to test them. Changing flags or deleting the module affects future requests; it cannot unload instructions already present in an active conversation, so start a fresh Codex or Copilot session after installation, removal, or when shedding loaded context.

## Qwen reasoning in Codex

The software and test engineers request `qwen/qwen3.5-9b` with `high` reasoning.
Codex validates reasoning effort against its model catalog before launching an agent.
If Qwen advertises an empty `supported_reasoning_levels` array, Codex rejects `high`
even when another client can use it through the same gateway.

For a gateway that supports Qwen high reasoning, generate an opt-in client catalog:

```powershell
./install/configure-model-catalog.ps1 -WhatIf
./install/configure-model-catalog.ps1
```

The helper reads `models_cache.json` from the resolved Codex home and writes
`models.toolkit.json` beside it. Use `-SourceCatalog PATH` for an existing custom
catalog or a profile-specific cache such as `models_cache.codex_work_desktop.json`.
Choose the source used by the intended host/profile so its complete model metadata
is retained. `-UserHome PATH` selects `PATH/.codex`; otherwise `CODEX_HOME` is honored,
falling back to the current user's `.codex` directory.

All model entries, instructions, context limits and existing reasoning levels are
preserved. Only Qwen receives a `high` capability if missing and a `high` default.
An absent or duplicate Qwen entry is rejected rather than synthesizing metadata.
The source is never changed. Repeated identical generation is a no-op; a differing
output requires explicit `-Force`. The normal copy installer does not run this helper.

Set the following at the root of the active Codex configuration, before any table
headers, using the absolute path printed by the helper:

```toml
model_catalog_json = "C:/Users/YOUR_USER/.codex/models.toolkit.json"
```

Replace an existing root value instead of adding a duplicate. A selected profile's
configuration can override this value. The helper does not edit personal configuration.
Restart Codex and launch a small software-engineer task. Confirm that the gateway
receives and forwards or translates `reasoning.effort = "high"` to the Qwen backend;
a successful launch proves client acceptance, not that the backend used high reasoning.
Copilot's reasoning controls remain host-specific.

To roll back, remove this setting or restore its previous value, then restart Codex.
The generated file may be removed after it is no longer referenced. Normal toolkit
unlink does not remove this separately generated catalog. Regenerate from the updated
active catalog after client/model metadata changes, reviewing differences before `-Force`.
Never commit a personal cache or generated catalog into the toolkit.

See the official [Codex configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)
for `model_catalog_json` and the [gateway catalog example](https://learn.chatgpt.com/docs/enterprise/bedrock-through-litellm)
for preserving complete model entries. That gateway example concerns Bedrock; it does
not establish Qwen backend support.

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
