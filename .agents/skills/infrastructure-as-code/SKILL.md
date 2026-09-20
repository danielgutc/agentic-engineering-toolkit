---
name: infrastructure-as-code
description: Design, implement, or review declarative infrastructure changes with reproducibility, least privilege, state safety, and rollback in mind. Use for Terraform, Bicep, CloudFormation, Pulumi, Kubernetes manifests, or equivalent IaC. Do not deploy or alter remote infrastructure without explicit authorization.
---

# Infrastructure as Code

Treat infrastructure changes as reviewed, testable software with operational consequences.

## Workflow

1. Identify the traced container or operational requirement, target environment, provider, state model, ownership boundary, and constraints.
2. Inspect existing modules, naming conventions, identity design, policy checks, and deployment workflow.
3. Define desired state, dependencies, migration sequence, rollback strategy, and drift expectations.
4. Make the smallest declarative change that fits the approved topology and supports safe evolution.
5. Validate formatting, syntax, static checks, policy tests, and a plan or dry run when safely available.
6. Inspect the proposed delta for replacement, deletion, privilege, cost, availability, and exposure risks.
7. Report validation evidence, rollout and rollback conditions, and approvals required before apply or deployment.

## Boundaries

- Never expose secrets in source, plans, logs, or responses.
- Never apply infrastructure changes without explicit authorization.
- Avoid state manipulation and destructive replacement unless separately approved.
- Prefer reusable modules only when they reduce demonstrated duplication without hiding critical behavior.
