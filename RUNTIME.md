# Atlas Runtime and agent-assisted installation

Atlas is free to use, including for professional and commercial work. Its engine
source remains private. See `FREE-USE-TERMS.txt` in the distribution.

Core owns one shared runtime for Core, Family, Sheets and Annotations. Install Core
and the specialist plugins you need from [Atlas Marketplace](https://github.com/mroshdy91/Atlas-Marketplace).
Then tell your agent: **“Set up RevitAtlas and check its connection to Revit.”**
The agent's setup instructions are packaged with the plugin and do not need a
working MCP connection. You should not need to paste commands or manage tokens.

## Current availability

Public beta **0.1.0-beta.1** provides the shared runtime for Revit 2025 and 2026. The packaged `runtime-release.json` pins the exact public release archive, manifest and installer hashes. Download access is anonymous; no private repository access is required. See [Core releases](https://github.com/mroshdy91/RevitAtlas.Core-Plugin/releases/tag/v0.1.0-beta.1).

## What setup does

The agent runs `scripts/atlas-setup.ps1 -Action Doctor`, then `-Action Install` when
installation is authorized. Setup verifies the pinned package, detects standard
Revit 2025 and 2026 installations, installs their matching add-ins, and provisions
the local connection. The runtime is self-contained; no development SDK is required.
Specialists reuse it and do not install another engine or background broker.

Atlas does not install or license Autodesk Revit. Save work and close Revit normally
when setup requires it. A client restart may be necessary to load the newly
configured connection. Windows/organization security prompts may still require
your interaction; the agent must not disable those protections.

Installation is per-user. Credentials stay local and are never embedded in public
packages or printed in setup results. Diagnostics distinguish missing software,
closed Revit, a required restart, changed package bytes and partial setup.

## Recovery

The installer returns a receipt. Its `Rollback` and `Uninstall` actions restore
previous selections only when those selections have not since been changed.
Models, work/evidence, credentials and versioned runtime folders are retained.
The agent uses the retained receipt; it must not delete your application-data folder.

Public repositories contain readable integration manifests, skills and setup
helpers. Compiled runtime files are downloadable, but implementation source and
debug symbols are excluded. Compiled software can still be inspected; distributing
binaries is not a guarantee against decompilation.
