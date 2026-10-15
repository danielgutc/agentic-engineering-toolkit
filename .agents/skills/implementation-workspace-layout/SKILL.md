---
name: implementation-workspace-layout
description: Define or adapt implementation workspaces for independently owned build, test, and packaging units in any language or technology. Use when repository layout must represent approved implementation boundaries. Do not use to decide service or container boundaries, or for ordinary feature edits within an established workspace.
---

# Implementation Workspace Layout

Organize implementation assets around approved ownership and lifecycle boundaries without treating a language project, C4 component, or deployable as an automatic directory boundary.

## Workspace boundary

An implementation workspace is a directory that owns a coherent set of source or customization assets, toolchain configuration, developer tests, documentation, and generated output. It commonly implements one approved application or service, but can also represent a database customization, container image, infrastructure extension, library family, or another independently maintained unit.

Use the existing architecture and repository conventions to identify the boundary. This skill places an approved unit; it does not create microservices, containers, components, or deployment boundaries. Do not create a workspace for an unmodified third-party image or managed service whose only repository-owned material is deployment configuration.

## Workflow

1. Inspect repository instructions, approved architecture, existing implementation roots, build entry points, language manifests, tests, CI paths, packaging, and ignored output. Distinguish repository-wide files from files that govern one implementation unit.
2. Choose a stable workspace name from the approved unit or established repository vocabulary. In a repository that separates design and implementation, prefer `implementation/<unit>/`. Preserve a well-established equivalent unless migration was requested.
3. Keep the workspace self-contained where the technology permits: source or customization assets, unit-local tests, developer documentation, build or package entry points, toolchain selection, and ignored generated output belong within its boundary. Use technology-native names and omit directories that have no owned content.
4. Keep repository-wide design, cross-workspace acceptance or integration tests, deployment orchestration, and release artifacts at their established repository-level locations. A test belongs in a workspace when it can be owned and run with that unit; it belongs at repository level when it verifies several workspaces or the assembled system.
5. Allow several projects, packages, or modules inside one workspace when they share ownership and lifecycle. Place independently built or operated units in sibling workspaces only when the approved architecture and delivery model require that separation.
6. Scope toolchain and build configuration to the smallest directory it intentionally governs. Do not leave language-specific solution, SDK, package, cache, or output settings at repository root merely because one nested workspace uses that language.
7. Before moving an established workspace, trace relative paths through manifests, project references, scripts, CI, containers, documentation, generated-file checks, IDE metadata, and ignore rules. Update consumers atomically and preserve history where practical.
8. Validate from the same entry points used by developers and CI. Confirm workspace discovery, build, unit or contract tests, packaging where applicable, ignored generated output, and repository-level integration paths.

## Typical shapes

One application containing several language projects:

```text
implementation/
  app/
    src/
    tests/
    docs/
    <workspace and toolchain files>
    artifacts/                 # generated and ignored
```

Several approved independent units:

```text
implementation/
  catalog-service/
    <technology-native workspace>
  billing-service/
    <technology-native workspace>
  reporting-database/
    migrations/
    schema/
    tests/
```

These are adaptable shapes, not required layers. A customized image might contain only a `Dockerfile`, configuration, tests, and documentation. A small library workspace might keep sources beside its manifest when that is the language convention.

## Boundaries

- Do not infer implementation ownership from folder names alone; preserve approved system, domain, and container boundaries.
- Do not equate every C4 component or language project with an implementation workspace.
- Do not add empty placeholders for possible future units.
- Do not move repository-wide configuration into a workspace when it intentionally governs every unit.
- Do not delete old paths or outputs until their consumers are migrated and the exact targets are verified.
