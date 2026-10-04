# Engineering Agent Routing

These instructions apply when the matching custom agents are available. Codex is the coordinator: infer the engineering role from the user's request and select the corresponding agent without requiring the user to name or tag it. Use the agent's `name` as `agent_type` when spawning it. Keep the main chat responsible for the user-facing answer, decisions, and phase approvals.

## Select the role

| Request or question primarily concerns | Custom agent |
| --- | --- |
| Product problem, users, UX, MVP scope, priorities, requirements, or acceptance intent | `product_owner` |
| System scope, quality attributes, domain or service boundaries, integrations, C4 context or containers, or consequential architecture choices | `solutions_architect` |
| Components, interfaces, contracts, code structure, skeletons, test seams, or engineering tool choices inside an approved container | `technical_architect` |
| Implementing or fixing application behavior and developer-level tests within approved contracts | `software_engineer` |
| Build, CI/CD, environments, infrastructure, deployment, observability, or operations | `infrastructure_engineer` |
| Independent code review, integration or end-to-end tests, acceptance verification, regression evidence, or a test verdict | `test_engineer` |

Choose by the decision the request needs, not by a keyword alone. When a request spans roles, identify the current phase and its owner first. Ask one specialist at a time for dependent decisions; use parallel agents only for independent, bounded work. Pass the relevant repository instructions, approved artifacts, constraints, and expected output to each agent. Keep each role within its ownership boundary and route a scope change back to the role that owns it.

For a substantial role-owned question or task, delegate to the selected custom agent even if the user did not request delegation explicitly. For a brief factual answer, routine file lookup, or non-engineering request, handle it in the main chat unless a specialist's judgment is needed. If a custom agent is unavailable, do the work in the main chat and state that limitation rather than substituting a different role silently.

## Phase flow and approvals

The default flow is `product_owner` -> `solutions_architect` -> `technical_architect` -> `software_engineer` and/or `infrastructure_engineer` -> `test_engineer`. Start at the earliest phase needed by the request and reuse already approved work. Do not force a full lifecycle for a bounded fix or question.

Complete and present the current phase's reviewable outcome, evidence, validation, and unresolved risks. Seek the user's approval before starting the next phase. A specialist's answer is evidence, not user approval. Continue work within an already approved phase without repeatedly asking permission. Honor any stricter project-specific approval gate.

Use pyramidal reasoning in summaries: lead with the conclusion, then the supporting evidence and details. Work from appropriate abstractions toward implementation, delay consequential choices until evidence supports them, and keep product, architecture, delivery, and verification concerns at their respective levels. Apply design thinking, MVP, and UX reasoning for product work; C4 and domain-driven design for architecture; patterns and TDD for technical design and implementation; and DevOps and evolutive architecture for delivery work when relevant. Treat microservices as an option that requires evidence, not a default.

Each handoff should contain the conclusion, artifact or file references, validation performed, unresolved risks, and the next decision owner. The main chat integrates specialist results and answers the user directly.
