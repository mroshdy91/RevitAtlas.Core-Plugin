# Checked family scripting

Use Core scripting for a task that needs unusual native operations within its declared family scope. Inspect `atlas_script.check` and `run` contracts and the current connection's admission. An unavailable typed operation, a rejected native member or a missing grant is not permission to switch to an unrestricted legacy server.

The source is a C# body using the admitted `scope.Document`, not a new add-in. Use `atlas_catalog` with `kind: api_symbols`, an exact native `api_type` and optional `api_member` to discover signatures and effects. These bounded pages use the same member policy as the compiler; they inspect metadata without running native getters or scripts. The current policy intentionally excludes application, file, document-lifecycle and arbitrary callback access.

Choose `read`, restoring `probe`, or verified `edit`. Supply the owned work ID, expected revision, exact source, declared effects, a closed result schema and independent expected-value assertions. The engine owns the transaction/probe boundary. Do not open your own transaction or assume a script's returned success proves engineering acceptance.

Run `check` first. Preserve the returned source/check digests and pass the identical checked specification to `run`, including verification and limits. Changed source, work revision, policy or loaded API identity requires a fresh check. The compiled-byte cache is an internal optimization, not permission to reuse stale admission.

Check the actual result, verification and restoration/commit receipt. A failed assertion must not be redefined merely to accept the observed geometry. Script assertions test the supplied expectations; requested source fidelity, physical behavior, saved reopening and visual acceptance remain independent requirements.

Loops and supported allocations have explicit limits and cooperative checkpoints. Native API calls may still take time between boundaries. After a client timeout, recover the same operation through `atlas_operation`; do not rerun the script under a new ID until the original outcome is reconciled. This facility is a constrained trusted-authoring interface, not hostile-code isolation or a hard native timeout.
