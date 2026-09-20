# RevitAtlas Core

Sessions, work identity, inspection, engineering intent, visual review, recovery and delivery. Core owns the shared broker and version-matched Revit engine.

**Release status: preparation only.** The first `v0.1.0-beta.1` release is a draft. This repository contains the client manifests and skills; no public runtime installer is available yet. Cloning it alone will not connect an AI client to Revit.

## Atlas marketplace

Atlas uses one shared runtime with focused plugins. [Atlas Core](https://github.com/mroshdy91/RevitAtlas.Core-Plugin) provides the common services; [Atlas Family](https://github.com/mroshdy91/RevitAtlas.Family-Plugin) adds family authoring. The existing [Atlas Marketplace](https://github.com/mroshdy91/Atlas-Marketplace) is the catalog. Sheets and Annotations are separate unreleased work and are not included here.

## Compatibility and connection

Revit 2025 and 2026 are release targets. Private 2025 workflows and focused 2026 checks exist, but they are not a claim of complete public two-version qualification. See [release readiness](RELEASE-READINESS.md).

The MCP manifest connects to the local shared broker on `127.0.0.1:18765`. Authentication uses `ATLAS_BEARER_TOKEN`; this repository contains no token. Use only the local credential provisioned by your compatible Core installation. Never post credentials in an issue. Public installation instructions and runtime assets will accompany the qualified release; do not substitute private developer packages.

## Contents and limitations

The common skill loads detailed references as needed. Discover current capabilities before changing a model. A successful operation is separate from a verified complete engineering deliverable. Generic content is not manufacturer certification. System-family and in-place authoring are outside the Family product boundary.

Implementation source, private test records, models, logs, credentials, compiled runtime and Autodesk libraries are excluded. Autodesk content must come from the user's licensed installation. Public visibility does not grant an open-source license; no license grant is added by this preparation.
