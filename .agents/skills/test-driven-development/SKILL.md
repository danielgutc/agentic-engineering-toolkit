---
name: test-driven-development
description: Implement a behavior change through a focused red-green-refactor loop. Use when executable behavior can be specified with an automated test and repository changes are authorized. Do not use for exploratory research, documentation-only work, or tests that cannot provide useful feedback.
---

# Test-Driven Development

Use tests to clarify and drive one observable behavior at a time.

## Workflow

1. Identify the approved requirement or contract identifier, observable behavior, owning boundary, and failure case.
   Set completion criteria and identify high-risk assumptions, including real dependencies where present. Check risky boundary assumptions early against approved dependencies, then grow the smallest complete behavior through focused TDD slices. Mocks alone do not establish that a real boundary works; report unavailable environments as evidence gaps.
2. Select the lowest test level that provides trustworthy feedback without crossing unrelated boundaries.
3. Add one focused executable specification and run it to confirm it fails for the expected behavioral reason.
4. Implement the smallest skeleton or production change that satisfies the specification.
5. Run the focused test, then the relevant surrounding unit or component suite.
6. Refactor structure only while tests remain green and public behavior remains stable.
7. Update traceability when the repository maintains it, then report behavior, evidence, and residual gaps.
   Complete relevant developer integration checks and required validation before handoff. Repeat passing checks only after relevant changes, failures, or unresolved concerns; return the concrete result when completion criteria pass.

## Boundaries

- Test observable behavior rather than private implementation details.
- Do not weaken assertions or production behavior merely to make a test pass.
- Do not mock domain behavior that should be exercised directly.
- Use the integration and end-to-end testing workflow for developer-owned real-boundary checks; independent acceptance remains a separate verdict. Include browser smoke evidence when the changed behavior has a UI.
- Escalate when the expected behavior is ambiguous or contradicts the current design.
