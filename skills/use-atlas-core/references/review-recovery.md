# Review and recovery

Supply an operation ID for a mutation when practical. After a timeout, generic client error or response-preparation error, inspect that same operation. Do not infer rollback or start a new mutation just because the response failed. A successful native receipt can coexist with a failed image response.

When the connected `atlas_operation` schema exposes `after_cursor`, start change tracking with an empty string and reuse the returned cursor for that same operation. `changed:false` omits repeated result data while retaining current state and recovery instructions; elapsed time and connection counters can still change. Keep the last full result, or omit `after_cursor` to retrieve it again. A cursor does not authorize access or prove acceptance. Use the returned wait request for pending work and stop waiting once the operation is terminal.

An acceptance feature uses 1–20 semantic targets. Whole-assembly overview views may contain more, but do not prove each small detail. If many features need proof, divide them into meaningful review requirements while preserving all requested coverage.

Bind the visual requirement to the intended view, context and exact target set. Prepare/capture that view, actually inspect its image, then record with its native image operation/hash and current revision. Do not rebind the requirement or change the camera between capture and recording. A new image does not require weakening or redefining the engineering requirement.

A stale-view or target mismatch result gives expected/captured identities and a request to inspect the bound view. If its feature targets differ, frame the exact required targets, then capture that same view and record a fresh judgment. If you changed only editorial intent, use the qualified review-reuse equivalence check; never declare equivalence yourself. An unavailable view needs a new binding and capture, not modified evidence files.

Geometry, physical controls, visual appearance and source fidelity are separate checks. A family-editor clipping view is not a verified section through internal solids. Use appropriate project section capabilities when available, or report this evidence gap.

If validation is incomplete, inspect the named failed engineering checks and follow their supported recovery requests. Preserve a partial report and native checkpoints if blocked. Native delivery verifies saved/reopened files; do not manually rewrite manifests or acceptance.

Long native operations use an execution budget independent of client wait. Nested load/reload/extraction, type tables, profile constraints, cumulative probes, lookup replacement and review/validation can use the declared long native budget; explicit typed budgets accept 1 second through 30 minutes. A deadline requests cooperative cancellation at a native boundary. Revit may still be inside an API call; pending cancellation is not rollback or permission to replay. Inspect execution basis, elapsed time, progress and the original operation identity.

Queued and running are different states. A qualified engine can terminate cancellation of a never-started request without waiting for Revit's dispatcher; verify the actual terminal receipt. Running cancellation remains cooperative. A modal receipt identifies the exact dialog and operation: resolve that prompt in the intended session, then recover the original request. Do not use a universal dialog response or close another Revit window.

Reuse unchanged review evidence only when the engine verifies its dependency scope. A new camera can reuse measured family content, but still needs its own image judgment. Real content edits and reopened work can require fresh measurement. A retained-response hash or preview image is not a signed acceptance result. At storage capacity, recover existing receipts and follow the operator's retention policy; never delete signed evidence to turn a blocked result into a pass.

After a Revit restart, the owner can inspect persisted work to recover its saved revision without transferring ownership. Resume against that revision before editing. A stale resume returns the retained revision in its error result.

A consumed form may render through an owning `GeomCombination`. Inspection and review disclose that identity and all constituents. Independent pixel attribution to a consumed member is rejected; explicitly choose the combination for whole-combination evidence. Read-only constituent material feedback names its owning combination. Material assignment to a combination affects its other constituents, so select that broader target intentionally.
