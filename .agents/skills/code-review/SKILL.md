---
name: code-review
description: Review a branch, diff, or selected files for correctness, regressions, security-relevant behavior, maintainability risks, and missing tests. Use when the user asks for review or independent verification. Do not edit code unless the user separately requests fixes.
---

# Code Review

Prioritize actionable defects over summaries and stylistic preferences.

## Workflow

1. Read applicable instructions and identify the intended behavior of the change.
2. Inspect the diff and trace affected execution paths beyond the changed lines.
3. Check boundary conditions, state transitions, error handling, compatibility, and operational effects.
4. Evaluate whether tests cover meaningful behavior and failure modes.
5. Validate suspected defects when practical; do not report speculation as fact.
6. Return findings ordered by severity with tight file and line references.
7. State explicitly when no findings are discovered and identify residual testing limitations.

## Boundaries

- Remain read-only unless fixes are explicitly requested.
- Avoid style-only findings unless readability masks a behavioral risk.
- Keep each finding focused on one concrete problem and its impact.
- Do not bury findings beneath a long change summary.
