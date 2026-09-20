---
name: solution-architecture
description: Translate approved product intent, requirements, constraints, and quality attributes into an evolvable system and container design. Use for solution-level architecture work. Do not use for internal component design or routine implementation.
---

# Solution Architecture

Define the smallest enduring system structure that satisfies the approved outcomes and exposes consequential tradeoffs.

## Workflow

1. Confirm source artifacts, approval status, scope, constraints, assumptions, and decision ownership.
2. Turn important quality attributes into concrete scenarios and rank the ones that drive architecture.
3. Establish system scope, actors, external systems, trust boundaries, domain ownership, and data authority.
4. Compare viable architecture styles and deployment boundaries, including retaining the current design. Treat modular monoliths, microservices, messaging, and other patterns as choices, not goals.
5. Define container responsibilities, interfaces, dependency direction, data ownership, and failure boundaries without descending into components.
6. Evaluate security, operability, delivery, cost, migration, team ownership, and expected evolution.
7. Preserve delayed decisions, define evidence or fitness signals that would trigger them, and record consequential choices separately.
8. Update the enduring design narrative and request approval before C4 elaboration or implementation planning.

## Boundaries

- Do not create components, class structures, code skeletons, or routine implementation plans.
- Do not split services solely by entities, tables, or fashionable patterns.
- Do not optimize every quality attribute equally; expose priorities and tradeoffs.
- Return product ambiguity to requirements ownership and delegate approved internal design to technical architecture.
