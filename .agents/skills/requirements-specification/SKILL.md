---
name: requirements-specification
description: Convert approved product intent into stable, testable functional and non-functional requirements, constraints, assumptions, and acceptance intent. Use for specification-driven requirements work. Do not use to choose architecture or implementation details.
---

# Requirements Specification

Create requirements that can guide design, implementation, and verification without prescribing an unjustified solution.

## Workflow

1. Confirm the approved product source, scope boundary, actors, vocabulary, and selected project workflow.
2. Assign stable identifiers and keep functional requirements, non-functional requirements, constraints, and assumptions distinct.
3. Express each functional requirement as observable behavior with a trigger, context, expected response, and relevant failure behavior. Use EARS syntax when it improves precision.
4. Express each non-functional requirement as a measurable quality scenario with scope, stimulus, operating condition, response, and target when evidence supports one.
5. Add acceptance examples for critical paths, boundary conditions, authorization, and failure cases without duplicating test implementation.
6. Check requirements for ambiguity, contradiction, duplication, hidden design choices, and missing product traceability.
7. Record feasibility questions for architecture roles and obtain approval before treating the specification as an enduring baseline.

## Workflow Order

- In requirements-first work, derive the specification from approved product direction before solution design.
- In design-first work, derive or refine it from approved product direction and the approved feasibility or design constraints.

## Boundaries

- Do not disguise architecture preferences as requirements.
- Do not invent numeric targets; identify the decision owner and evidence needed.
- Keep acceptance intent observable and technology-neutral unless technology is an approved constraint.
- Return product ambiguity to the product owner and feasibility conflicts to the appropriate architect.
