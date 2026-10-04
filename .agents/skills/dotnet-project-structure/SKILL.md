---
name: dotnet-project-structure
description: Create or adapt the repository layout of .NET 8+ SDK solutions, including centralized artifacts output. Use when scaffolding projects or changing solution structure. Do not use for ordinary application features or to impose architecture layers on an established repository.
---

# .NET Project Structure

Use the SDK's artifacts output layout for new .NET 8+ repositories while keeping project structure and build configuration consistent with the repository's actual needs. The output layout is a build convention, not a reason to introduce domain layers, services, or projects without an approved need.

## Workflow

1. Inspect `global.json`, installed SDK, target frameworks, solution files, project files and references, `Directory.Build.props` and `.targets` (including nested files), `Directory.Packages.props`, custom output paths, `.gitignore`, and build or CI commands. Identify existing conventions before proposing edits.
2. For a new repository, put production projects under `src/` and test projects under `tests/`, with a solution at the repository root when useful. Create only the projects justified by the requested product and design. For an established repository, preserve its layout unless the user requested migration; move projects only after checking solution membership, project references, imports, scripts, and CI paths.
3. For .NET 8+ projects that can share the convention, configure `UseArtifactsOutput` in the repository-level `Directory.Build.props`. Use [the template](assets/Directory.Build.props) when creating that file. If it exists, merge the property into its existing MSBuild structure; do not replace the file. Check that nested props, explicit `OutputPath` or `IntermediateOutputPath`, and SDK version constraints do not defeat the intended output layout. Resolve project-name collisions before sharing artifact folders.
4. Add the root-anchored [gitignore fragment](assets/gitignore.fragment) to the repository's `.gitignore` without discarding existing rules. Use [the optional central package template](assets/Directory.Packages.props) only when central package management is appropriate; add actual package versions and remove project-level `Version` attributes as part of that separate change. Do not enable it merely to centralize build artifacts.
5. Run restore, build, and the available tests through the repository's standard commands or `dotnet restore`, `dotnet build --no-restore`, and `dotnet test --no-restore`. Confirm the expected projects appear beneath `artifacts/bin/<project>/<pivot>/` and `artifacts/obj/<project>/<pivot>/`; `publish/` and `package/` appear only when those operations run. Confirm generated artifacts are ignored. Report any command that cannot run or any intentional exception.

## Migration boundaries

- Treat mixed SDK generations, nested build props, customized output paths, and existing CI assumptions as compatibility decisions. Make the smallest safe change and explain unresolved conflicts.
- Do not delete existing `bin/` or `obj/` directories solely because new builds use `artifacts/`.
- Do not infer dependency direction from folder names alone; preserve approved architecture when adjusting project references.

The SDK format and pivot rules are documented in [Artifacts output layout](https://learn.microsoft.com/dotnet/core/sdk/artifacts-output). See [Central Package Management](https://learn.microsoft.com/nuget/consume-packages/central-package-management) for the optional package-version convention.
