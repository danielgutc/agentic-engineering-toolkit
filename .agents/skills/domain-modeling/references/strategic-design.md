# Strategic Domain Design

Use strategic design to decide where models and ownership boundaries should differ.

## Method

1. Classify subdomains as core, supporting, or generic based on business differentiation and investment needs.
2. Propose bounded contexts where language, rules, consistency, ownership, or rate of change diverge.
3. Give every context a purpose, model, owning capability, inputs, outputs, and explicit boundary.
4. Map relationships between contexts, including upstream and downstream influence, translation, published language, and anti-corruption needs.
5. Evaluate organizational ownership, data authority, transactional consistency, coupling, and independent change before proposing deployment boundaries.
6. Validate the context map against concrete business scenarios and known evolution pressures.

## Outputs

- Ubiquitous language by context
- Subdomain classification
- Bounded-context responsibilities and ownership
- Context relationships and integration semantics
- Candidate deployment boundaries, clearly marked as candidates
- Open domain decisions and evidence needed

Microservices may implement some bounded contexts, but operational independence, scaling, release cadence, failure isolation, and team ownership must justify that choice separately.
