---
name: domain-modeling
description: Model domain language, behavior, boundaries, and invariants using strategic or tactical domain-driven design. Use when domain complexity affects requirements or software boundaries. Do not use to force DDD patterns onto simple data-centric work.
---

# Domain Modeling

Build a shared model of the business domain at the abstraction level needed by the current decision.

## Shared Workflow

1. Gather scenarios, rules, terminology, actors, events, and examples from domain evidence.
2. Resolve ambiguous terms and maintain a ubiquitous language tied to the context where each term applies.
3. Model behavior, ownership, decisions, and invariants before data structures.
4. Test the model against normal, boundary, and failure scenarios with domain participants or approved requirements.
5. Record unresolved domain questions and keep architecture or implementation choices separate until justified.

## Select a Mode

- Read [Strategic design](references/strategic-design.md) for subdomains, bounded contexts, context maps, ownership, or candidate service boundaries.
- Read [Tactical design](references/tactical-design.md) for aggregates, entities, value objects, domain services, events, repositories, or executable domain models.
- Use both only when a task genuinely crosses strategic and tactical design.

## Boundaries

- Do not assume one bounded context requires one deployable service.
- Do not introduce aggregates, repositories, or domain events without behavior or invariants that justify them.
- Do not let persistence schemas or framework types define the domain model.
- Escalate changes that alter approved product meaning or system ownership.
