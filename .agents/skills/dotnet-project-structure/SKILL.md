---
name: dotnet-project-structure
description: Create or adapt .NET 8+ SDK solutions and projects within an approved implementation workspace, including SDK selection and centralized artifacts output. Use when scaffolding or migrating .NET structure. Do not use to choose service boundaries or for ordinary application features.
---

# .NET Project Structure

Apply this skill after the owning implementation workspace is known. Use $implementation-workspace-layout first when that boundary or its repository placement must be created or changed. A .NET solution is a workspace entry point and can contain several projects; it is not automatically the repository root, a service boundary, or a C4 container.

Use the SDK's artifacts output layout while keeping project structure and build configuration scoped to the .NET workspace. The output layout is a build convention, not a reason to introduce domain layers, services, or projects without an approved need.

## Workflow

1. Inspect the approved implementation workspace, `global.json` discovery path, installed SDKs, target frameworks, solution files, project files and references, `Directory.Build.props` and `.targets` (including nested files), `Directory.Packages.props`, custom output paths, `.gitignore`, and developer or CI commands. Identify which settings are repository-wide and which belong to this workspace.
2. For a new workspace, normally place production projects under `src/`, developer-level test projects under `tests/`, workspace documentation under `docs/`, and the solution plus `global.json` at the workspace root. Create only the solution and projects justified by the approved design. Use sibling solutions or workspaces for independent services only when their ownership and lifecycle are already approved.
3. Pin the SDK with a workspace-root `global.json` when the workspace requires .NET toolchain selection. The .NET CLI starts its `global.json` search from the current working directory, so run commands from the workspace or a descendant. Keep a repository-root `global.json` only when it intentionally governs every .NET workspace. Approved independent services that require incompatible SDK versions should use separate implementation workspaces, each with its own `global.json` and build root. When one implementation unit deliberately contains nested toolchain roots, document which paths each root governs and the working directory for every build, test, and CI entry point.
4. Configure .NET 8+ projects that share the workspace convention with a workspace-root `Directory.Build.props`. MSBuild searches upward from each project and normally uses the first matching file; it does not automatically merge a parent file. Use [the template](assets/Directory.Build.props), which sets `UseArtifactsOutput` and anchors `ArtifactsPath` to the directory containing that props file. If the file exists, merge the properties into its MSBuild structure; do not replace it. Check deliberate parent imports, nested props, explicit `OutputPath`, `IntermediateOutputPath`, or `ArtifactsPath`, and SDK constraints. Resolve project-name collisions before projects share the artifacts directory.
5. Add [the ignore fragment](assets/gitignore.fragment) to a workspace-local `.gitignore`, or translate it to the exact workspace path in the repository-root `.gitignore`, such as `/implementation/<unit>/artifacts/`. Do not use a root `/artifacts/` rule when generated output is nested elsewhere. Use [the optional central package template](assets/Directory.Packages.props) only when central package management is appropriate for this workspace; add actual package versions and remove project-level `Version` attributes as part of that separate change.
6. For an established workspace, preserve its layout unless migration was requested. Before moving projects or toolchain files, check solution membership, project and import paths, scripts, CI working directories, container build contexts, test launch paths, IDE entry points, documentation, package output, and ignore rules.
7. Run restore, build, and the available tests from the workspace through its standard commands or `dotnet restore`, `dotnet build --no-restore`, and `dotnet test --no-restore`. Confirm the expected projects appear beneath the workspace's `artifacts/bin/<project>/<pivot>/` and `artifacts/obj/<project>/<pivot>/`; `publish/` and `package/` appear only when those operations run. Confirm generated artifacts are ignored and repository-level integration commands still locate the outputs. Report any command that cannot run or any intentional exception.

## Migration boundaries

- Treat mixed SDK generations, nested build props, customized output paths, and existing CI assumptions as compatibility decisions. Make the smallest safe change and explain unresolved conflicts.
- Do not delete existing `bin/` or `obj/` directories solely because new builds use `artifacts/`.
- Do not infer dependency direction from folder names alone; preserve approved architecture when adjusting project references.
- Do not move unrelated repository assets beneath the .NET solution or make .NET settings govern sibling non-.NET workspaces accidentally.

The SDK format and pivot rules are documented in [Artifacts output layout](https://learn.microsoft.com/dotnet/core/sdk/artifacts-output). See [Customize the build by directory](https://learn.microsoft.com/visualstudio/msbuild/customize-by-directory) for `Directory.Build.props` discovery, [.NET SDK selection](https://learn.microsoft.com/dotnet/core/tools/global-json) for `global.json` discovery, and [Central Package Management](https://learn.microsoft.com/nuget/consume-packages/central-package-management) for the optional package-version convention.
