# First public release readiness

Status: NOT READY FOR PUBLIC RUNTIME INSTALLATION.

Prepared: separate public Core/Family client repositories, token-free MCP manifests, focused skills, content hashes and draft release notes.

Remaining shared gates:

- Sanitize the runtime package and admission evidence. The private installer requires private qualification records; they must not be published.
- Implement and qualify installation, upgrade, rollback and uninstall for Revit 2025 and 2026, preserving user work and credentials.
- Complete affected Family/Revit 2026 native qualification. Compilation and documentation-specific checks do not qualify every family capability.
- Verify the clean public client/runtime pair and restart recovery, publish exact runtime hashes and dependency pins, and resolve distribution licensing and third-party notices.
- Publish immutable qualified assets, then enable their pinned marketplace entries.

These gates do not depend on declaring the separate Sheets/Annotations trials successful. Runtime assets must not be replaced by a client-only archive or private development bundle.
