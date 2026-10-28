---
name: technical-design
description: Refine an approved container into components, interfaces, code structure, test seams, executable skeletons, and engineering-tool requirements. Use for implementation-ready technical architecture. Do not use to redefine system scope or container boundaries.
---

# Technical Design

Create an implementation-ready internal design while preserving the approved solution boundaries.

## Workflow

1. Confirm the owning container, requirement identifiers, architecture decisions, constraints, and unresolved risks.
2. Partition components by cohesive responsibility, domain ownership, change pattern, and dependency direction rather than framework layer alone.
3. Define interfaces and contracts, including inputs, outputs, errors, authorization, idempotency, cancellation, compatibility, and versioning where relevant.
4. Model important flows, state transitions, transactions, concurrency, external calls, and failure recovery.
5. Select design patterns only when their forces match the problem and document the simpler alternative considered.
6. Define unit, component, contract, and integration test seams plus the first architecture-significant TDD slices.
7. Specify the minimal code skeleton and engineering toolset needed for feedback, static analysis, API checks, formatting, and documentation generation. When the approved unit needs a new or changed filesystem boundary, use $implementation-workspace-layout before applying language-specific structure.
8. Validate the design against container responsibilities and hand off bounded implementation slices with explicit acceptance evidence.

## MVP application

For MVP version 1.0, use the intended final technical architecture for the included scope; do not postpone required boundaries or contracts as an MVP shortcut. Show how known approved extensions fit without a corrective rewrite, avoid speculative abstractions, and identify PoC mechanisms that need qualification or removal before release.

## Boundaries

- Escalate any required change to system, domain, or authoritative container boundaries.
- Do not fill routine method bodies when contracts and a representative slice prove the design.
- Avoid speculative interfaces, extension points, layers, and patterns.
- Keep technology-specific details inside the owning container and preserve traceability to requirements and architecture.
- Defer repository placement to $implementation-workspace-layout when the task changes an implementation unit rather than only its internal component design.
