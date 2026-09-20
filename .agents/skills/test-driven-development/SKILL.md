---
name: test-driven-development
description: Implement a behavior change through a focused red-green-refactor loop. Use when executable behavior can be specified with an automated test and repository changes are authorized. Do not use for exploratory research, documentation-only work, or tests that cannot provide useful feedback.
---

# Test-Driven Development

Use tests to clarify and drive one observable behavior at a time.

## Workflow

1. Identify the requirement, user-visible behavior, boundary, and failure case.
2. Select the lowest test level that provides trustworthy feedback.
3. Add one focused test and run it to confirm it fails for the expected reason.
4. Implement the smallest production change that satisfies the test.
5. Run the focused test, then the relevant surrounding suite.
6. Refactor only while tests remain green.
7. Report the behavior covered, commands run, and residual gaps.

## Boundaries

- Test observable behavior rather than private implementation details.
- Do not weaken assertions or production behavior merely to make a test pass.
- Do not mock domain behavior that should be exercised directly.
- Escalate when the expected behavior is ambiguous or contradicts the current design.
