# Agent-assisted Atlas setup

Use this reference when Atlas tools are missing, the MCP connection fails, or the
user asks to install or repair Atlas. It is available before the runtime connects.
An ordinary modelling request does not authorize replacing a working installation
with a different candidate. Do not repeat identical setup approval questions when
the user has already asked to install or repair this integration.

## First use

Explain briefly that Core supplies one shared Windows runtime for all four plugins.
The user should not need to copy commands, find DLLs or manage connection secrets.
Run the packaged helper yourself using the client's shell capability:

```powershell
& '<installed atlas-core plugin>/scripts/atlas-setup.ps1' -Action Doctor
```

Resolve the placeholder from the actual installed Core skill location: the plugin
root is two levels above `skills/use-atlas-core`. Never guess a cache version.
If Core is absent, use the client's supported marketplace installation flow to
install `atlas-core` from the user's selected Atlas Marketplace. Do not create an
extra global MCP entry. Installing only a specialist does not install Core's runtime.

When setup is authorized and Doctor says the runtime is missing, run:

```powershell
& '<installed atlas-core plugin>/scripts/atlas-setup.ps1' -Action Install
```

The helper uses the plugin's `runtime-release.json`, requiring a published exact
version, official Core release asset and SHA-256 pins. It verifies the archive,
manifest, installer and every installed file. It detects Revit 2025/2026, registers
only installed versions, installs one shared self-contained runtime and configures
the local credential. No SDK, GitHub login or manual token entry is needed.
Never invent a release, edit its descriptor to pass a gate, use a private developer
bundle, or fetch and execute an unpinned “latest” installer.

## Conditions and recovery

- `PUBLIC_RUNTIME_NOT_RELEASED`: explain that no installable public runtime exists
  for this plugin yet. Report the release link; do not claim setup succeeded.
- `REVIT_PREREQUISITE_MISSING`: licensed Revit is a separate user prerequisite.
  This helper detects standard Autodesk install locations. A custom installation
  needs verified paths and maintainer guidance, not an invented supported version.
- `APPLICATIONS_RUNNING` / `REVIT_RESTART_REQUIRED`: save authorized work and close
  Revit normally. Do not terminate it, close unrelated user documents, or overwrite
  loaded binaries. Wait for Core's broker to exit after Revit closes, then retry.
- `pending`: retain the returned process/result identity and read that result;
  do not dispatch another installation. A pending launch is not success.
- `PACKAGED_HOST_REDIRECTION`: the helper attempts one independent Windows setup
  launch so normal Revit can see the files. If blocked, report the exact result.
- Hash mismatch, existing credential conflict, altered files, or Windows policy
  denial: stop that installation and explain the specific condition. Do not change
  execution policy, disable protection, expose credentials, or delete old state.
- `INSTALLATION_PARTIAL`: retain its receipt. Use the verified runtime installer's
  `Rollback -Receipt <returned receipt>` to restore only unchanged owned selections.
  Never manually rewrite runtime manifests or evidence.
- `CLIENT_RESTART_REQUIRED`: the helper has provisioned the user's local connection;
  the AI client must restart to inherit it. Request that restart only when needed.

After installation, open the requested Revit version normally and use `atlas_status`.
Verify the actual engine version and session, then perform bounded inspection through
the selected specialist. A Doctor result or installer success is not a live Revit test.
Do not read engine source or run arbitrary Revit scripts as a setup workaround.

The install receipt records the original selections for rollback. Uninstall restores
those selections and retains models, credentials, work/evidence and immutable package
folders. It does not silently purge user data. Updating compatible specialist plugins
does not require installing another engine or broker.
