---
name: repository-assessment
description: Map an unfamiliar repository, its governing instructions, architecture, entry points, tests, and risks before proposing work. Use for codebase orientation, impact discovery, or evidence gathering. Do not use when the relevant files and execution path are already known.
---

# Repository Assessment

Build a compact evidence base that another agent can use without repeating the same repository scan.

## Workflow

1. Read applicable agent instructions and the top-level project documentation.
2. Inventory the repository with targeted file search; exclude generated, dependency, and VCS directories.
3. Identify product, requirements, design, C4, implementation, infrastructure, test, and traceability artifacts that govern the task.
4. Record the current lifecycle stage and explicit approval evidence without inferring approval from file existence.
5. Identify languages, build tools, entry points, deployment artifacts, tests, and validation commands.
6. Trace only the code paths and artifact relationships relevant to the stated task.
7. Separate observed facts from inferences and unresolved questions.
8. Return the evidence pack described in `references/evidence-pack.md`.

## Boundaries

- Remain read-only unless the user separately authorizes changes.
- Prefer targeted searches over reading entire directory trees.
- Do not recommend architecture before identifying requirements and constraints.
- Do not mix product, system, container, component, and code-level conclusions.
- Do not repeat facts already established by a trustworthy prior handoff; verify only what affects the task.
