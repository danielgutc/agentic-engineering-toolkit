---
name: c4-modeling
description: Create or review enduring C4 system context, container, component, or code-level architecture artifacts. Use after the relevant architecture direction is understood and approved. Do not use to invent architecture or to document temporary implementation plans.
---

# C4 Modeling

Express approved architecture at the smallest C4 level needed by the audience.

## Workflow

1. Confirm the approved design or architecture decision, owning role, and identifiers that the model represents.
2. Select the smallest sufficient level: context for people and systems, container for runtime or data boundaries, component for internal responsibilities, or code for selected implementation structure.
3. Define the scope and boundary before adding elements.
4. Assign stable element identifiers and use names consistent with the product and domain vocabulary.
5. Describe responsibilities, interfaces, and directional relationships rather than merely listing technologies.
6. Keep diagrams readable by splitting distinct concerns rather than overloading one view.
7. Trace relevant requirements and decisions to modeled elements without turning the diagram into a matrix.
8. Align narrative and diagrams, then verify every element against the approved design and its owning abstraction.

## Boundaries

- Do not create containers or components without architectural justification.
- Do not use a lower abstraction level when a higher level answers the question.
- Do not equate bounded contexts, repositories, deployment units, and microservices without an explicit design decision.
- Keep transient task plans outside enduring C4 documentation.
- Follow the repository's selected diagram source format and naming conventions.
- If code-level views are generated from source, regenerate and validate them instead of manually editing their output.
