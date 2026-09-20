---
name: architecture-decision
description: Evaluate and document a consequential software architecture decision with context, options, tradeoffs, and consequences. Use for decisions that affect system boundaries, quality attributes, dependencies, data, or operations. Do not use for routine implementation choices with an obvious reversible answer.
---

# Architecture Decision

Develop a decision from evidence while delaying commitments that are not yet justified.

## Workflow

1. State the decision, owning role, abstraction level, scope, and why it is needed now.
2. Gather traced requirements, constraints, quality-attribute scenarios, existing decisions, and evolution pressures.
3. Define weighted evaluation criteria before comparing options.
4. Consider at least two viable options, including retaining the current design when applicable.
5. Compare benefits, costs, risks, reversibility, migration, operations, and future change consequences.
6. Recommend an option or explicitly defer the decision when evidence is insufficient.
7. Define validation or fitness signals and conditions that should reopen the decision.
8. Request approval from the decision owner before updating enduring architecture or beginning dependent work.
9. When documentation is requested, use `assets/adr-template.md`.

## Boundaries

- Do not force distributed systems, microservices, patterns, or infrastructure without demonstrated need.
- Distinguish assumptions from accepted constraints.
- Prefer reversible decisions and explicit decision points.
- Keep the decision at one declared abstraction level; route wider consequences to their owners.
- Keep implementation detail out unless it materially affects feasibility.
