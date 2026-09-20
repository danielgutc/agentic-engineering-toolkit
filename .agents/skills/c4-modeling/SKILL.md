---
name: c4-modeling
description: Create or review enduring C4 system context, container, component, or code-level architecture artifacts. Use after the relevant architecture direction is understood and approved. Do not use to invent architecture or to document temporary implementation plans.
---

# C4 Modeling

Express approved architecture at the smallest C4 level needed by the audience.

## Workflow

1. Confirm the architecture decision or design source that the model represents.
2. Select the appropriate level: system context, container, component, or code.
3. Define the scope and boundary before adding elements.
4. Name people, systems, containers, and components consistently with the project vocabulary.
5. Describe responsibilities and relationships, not merely technologies.
6. Keep diagrams readable by splitting distinct concerns rather than overloading one view.
7. Align the narrative and diagrams, then verify every element against the approved design.

## Boundaries

- Do not create containers or components without architectural justification.
- Do not use a lower abstraction level when a higher level answers the question.
- Keep transient task plans outside enduring C4 documentation.
- Follow the repository's selected diagram source format and naming conventions.
