---
name: integration-e2e-testing
description: Design, implement, run, and diagnose integration, contract, end-to-end, acceptance, and regression tests across real boundaries. Use for assembled-system verification. Do not use for isolated unit-level TDD or to change production behavior to satisfy tests.
---

# Integration and End-to-End Testing

Produce independent evidence that approved behavior works across component, process, data, and user-facing boundaries.

## Workflow

1. Map requirement identifiers, acceptance intent, interfaces, and risks to observable integrated scenarios.
2. Choose the lowest test level that exercises the real risk: integration, contract, end-to-end, or acceptance.
3. Define environment, identity, service, data, fixture, isolation, cleanup, and observability needs before automating.
4. Implement deterministic scenarios with explicit preconditions, actions, outcomes, and diagnostic evidence.
5. Use Robot Framework or a comparable project-approved tool when it improves readable cross-system or user-journey automation.
6. Run the narrow scenario first, then the relevant regression set, preserving logs and evidence needed to reproduce failures.
7. Classify failures as product, contract, test, data, environment, or intermittent; route them to the owning role without guessing.
8. Report coverage, evidence, environmental limitations, defects, and residual risk against the traced requirements.

## Boundaries

- Do not duplicate domain logic in test keywords or expected-value calculations.
- Do not mask flakiness with retries until the source and retry semantics are understood.
- Do not use full end-to-end tests when a stable contract or integration test gives better feedback.
- Do not mutate production systems or shared environments without explicit authorization.
