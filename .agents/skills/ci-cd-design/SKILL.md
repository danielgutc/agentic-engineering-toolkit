---
name: ci-cd-design
description: Design, implement, or review continuous-integration and delivery workflows, quality gates, artifact promotion, and rollback controls. Use for pipeline or release-engineering tasks. Do not trigger deployments or mutate external environments without explicit authorization.
---

# CI/CD Design

Create DevOps feedback and delivery workflows that are reproducible, observable, secure, and proportional to project risk.

## Workflow

1. Identify change sources, traced quality requirements, target environments, release frequency, compliance needs, and failure tolerance.
2. Inspect existing build, test, packaging, secret, deployment, and observability conventions.
3. Separate fast feedback, unit and component validation, integrated verification, artifact creation, promotion, deployment, and post-deployment checks.
4. Build an immutable artifact once and promote it between environments where practical.
5. Apply least privilege, protected environments, explicit approvals, and concurrency controls.
6. Define failure reporting, retry semantics, deployment health signals, rollback, and recovery ownership.
7. Validate pipeline syntax and safe non-deployment paths before proposing activation.

## Boundaries

- Do not place credentials or secret values in pipeline definitions.
- Do not deploy or enable a production workflow without explicit authorization.
- Avoid duplicating commands that belong in repository build scripts.
- Keep platform-specific choices aligned with project constraints rather than personal preference.
