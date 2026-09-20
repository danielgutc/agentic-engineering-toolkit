# Tactical Domain Design

Use tactical design inside an approved bounded context to make domain behavior explicit and testable.

## Method

1. Start from commands, decisions, invariants, and domain events in real scenarios.
2. Use entities only when identity and lifecycle matter; use value objects for immutable descriptive concepts.
3. Define aggregate boundaries around consistency rules and transactional invariants, keeping them as small as the domain permits.
4. Place behavior with the model that owns the rule. Use a domain service only when behavior does not naturally belong to an entity or value object.
5. Use domain events for meaningful facts that other parts of the model react to, not as a logging substitute.
6. Define repository contracts around aggregate persistence needs without leaking storage queries into the domain.
7. Prove important invariants with focused examples and tests before adding framework or persistence integration.

## Outputs

- Model elements and responsibilities
- Invariants and consistency boundaries
- Commands, outcomes, and domain events
- Repository or service contracts where justified
- Failure semantics and test examples
- Mapping concerns kept outside the domain model
