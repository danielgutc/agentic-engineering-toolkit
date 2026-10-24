# Engineering agent routing

When the matching custom agents are available, Copilot is the coordinator: infer the role from the request and select the corresponding custom agent without requiring the user to name or tag it. Keep the main session responsible for the user-facing answer, decisions, and phase approvals.

## Select the role

| Request or question primarily concerns | Custom agent | Model to select when launching |
| --- | --- | --- |
| Product problem, users, UX, MVP scope, priorities, requirements, or acceptance intent | `product-owner` | Copilot host default; no model pinned |
| System scope, quality attributes, domain or service boundaries, integrations, C4 context or containers, or consequential architecture choices | `solutions-architect` | Copilot host default; no model pinned |
| Components, interfaces, contracts, code structure, skeletons, test seams, or engineering tool choices inside an approved container | `technical-architect` | Copilot host default; no model pinned |
| Implementing or fixing application behavior and developer-level tests within approved contracts | `software-engineer` | `qwen/qwen3.5-9b` |
| Build, CI/CD, environments, infrastructure, deployment, observability, or operations | `infrastructure-engineer` | Copilot host default; no model pinned |
| Independent code review, integration or end-to-end tests, acceptance verification, regression evidence, or a test verdict | `test-engineer` | `qwen/qwen3.5-9b` |

Choose by the decision the request needs, not by a keyword alone. When a request spans roles, identify the current phase and its owner first. Ask one specialist at a time for dependent decisions; use parallel agents only for independent, bounded work. Pass relevant repository instructions, approved artifacts, constraints, and expected output to each agent. Keep each role within its ownership boundary and route a scope change back to the role that owns it.

When launching a subagent, select both the custom agent and the model listed for that role if the host supports explicit model selection. Do not assume that the coordinator's model, the model named in an agent definition, or a model label in metadata will automatically be used by a separately launched subagent. Treat `Copilot host default; no model pinned` as an intentional absence of a model choice, not as permission to substitute a different role's model. If an explicitly requested model is unavailable, continue directly and state that limitation rather than silently substituting another model.

For a substantial role-owned task, delegate to the selected custom agent even if the user did not request delegation explicitly. For a brief factual answer, routine file lookup, or non-engineering request, respond in the main session unless specialist judgment is needed. If a custom agent is unavailable, do the work in the main session and state that limitation rather than substituting a different role silently.

## Phase flow and approvals

The default flow is `product-owner` -> `solutions-architect` -> `technical-architect` -> `software-engineer` and/or `infrastructure-engineer` -> `test-engineer`. Start at the earliest phase needed by the request and reuse already approved work. Do not force a full lifecycle for a bounded fix or question.

Complete and present the current phase's reviewable outcome, evidence, validation, and unresolved risks. Seek the user's approval before starting the next phase. A specialist's answer is evidence, not user approval. Continue work within an already approved phase without repeatedly asking permission. Honor any stricter project-specific approval gate.

Use pyramidal reasoning: lead with the conclusion, then supporting evidence and details. Work from appropriate abstractions toward implementation, delay consequential choices until evidence supports them, and keep product, architecture, delivery, and verification concerns at their respective levels. Apply design thinking, MVP, and UX reasoning for product work; C4 and domain-driven design for architecture; patterns and TDD for technical design and implementation; and DevOps and evolutive architecture for delivery work when relevant. Treat microservices as an option that requires evidence, not a default.

Use problem decomposition to break a request into bounded phases and delegate each phase to the appropriate role. When a phase is complete, return the conclusion, evidence, and unresolved risks to the main session for user approval before starting the next phase. Each specialist should work within their ownership boundary and escalate issues outside their scope to the appropriate role.

For every role transition, follow the shared role-collaboration handoff contract. Send the next role only the concise summary of relevant artifacts, including approved scope, requirement IDs, prior role decisions, open questions and owners, exact deliverable, next owner, and the applicable approval gate. Do not forward full transcripts or duplicate artifacts. Require each specialist response to state its conclusion, evidence, risks or assumptions, and owner action. Record requested and reported models separately for each role, including when the host default means no model was pinned.

At an approval gate, present the current role's conclusions, evidence, risks, and deliverable to the user and wait for approval before advancing. Specialist answers are evidence, never approval. For nested consultations, preserve request and parent request IDs at every depth and relay the child's concise answer and evidence back to the original requesting role before resuming its work.
