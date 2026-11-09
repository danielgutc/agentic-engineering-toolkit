---
name: repository-assessment
description: Map an unfamiliar repository, its governing instructions, architecture, entry points, tests, and risks before proposing work. Use for codebase orientation, impact discovery, or evidence gathering. Do not use when the relevant files and execution path are already known.
---

# Repository Assessment

Build a compact evidence base that another agent can use without repeating the same repository scan.

## Workflow

1. Read applicable agent instructions and project documentation relevant to the question.
2. Search the relevant repository areas; broaden the inventory when the execution path or ownership is unclear. Exclude generated, dependency, and VCS directories.
3. Identify the requirements, design, implementation, infrastructure, and test artifacts that govern the task. When workspace boundaries affect the question, distinguish implementation workspaces from repository-level orchestration and cross-workspace tests.
4. Record lifecycle stage and explicit approval evidence when they affect the requested work, without inferring approval from file existence.
5. Identify relevant entry points, tools, tests, and validation commands. Include workspace ownership, toolchain scope, generated output, and project or package structure when needed to explain the execution path or impact.
6. Trace only the code paths and artifact relationships relevant to the stated task.
7. Separate observed facts from inferences and unresolved questions.
8. Return the findings and file references needed to answer the question or continue the work. For broader orientation or a handoff spanning several areas, use the relevant sections of [the evidence pack](references/evidence-pack.md).

## Boundaries

- Remain read-only unless the user separately authorizes changes.
- Prefer targeted searches over reading entire directory trees.
- Do not recommend architecture before identifying requirements and constraints.
- Do not mix product, system, container, component, and code-level conclusions.
- Do not repeat facts already established by a trustworthy prior handoff; verify only what affects the task.
- Do not infer services, containers, or ownership boundaries from language projects or directory names alone.
