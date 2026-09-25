# Execution plans

Use the installed `atlas_execute.run` contract to determine admitted steps and policies. Current bounded plans accept up to32 named steps and4 explicit work scopes. Work identities and revisions come from Core; a plan does not create specialist authority. Prefer one plan for a known related sequence instead of separate calls that only pass IDs between actions.

Choose the native effect boundary required by the task:

| Policy | Behavior |
|---|---|
| `checkpointed_stages` | Each completed stage retains its effects. Later failure or cancellation preserves those stages and their receipts. Supports typed references to earlier completed outputs. |
| `read_bundle` | Eligible reads share one native family context. Check `consistent` before combining results; an incomplete bundle can retain earlier reads with `consistent:false`. |
| `single_document_atomic` | Eligible literal-input actions share one family transaction group. A successful group publishes one model revision; a proven rollback restores the original work state. |

Read bundles and atomic groups currently use one owned family, with no output references. Atomic eligibility is deliberately narrower than checkpointed eligibility; shared-definition files, lifecycle actions, file operations and multi-document work are excluded. Discover actual eligible actions instead of inferring eligibility from an action being typed. Read-only atomic groups do not create model revisions.

When the current catalog admits drawing stages, a checkpointed plan can combine sheet layout, crop, native tag layout and project-value edits across declared family-work scopes. Keep each owned project key inside its correct work scope. These stages edit project documents and are excluded from family atomic groups and read bundles. A later failed tag/layout action does not undo a successfully committed earlier Mark or sheet change; recover the parent and use its per-work revisions before continuing.

Select `execution_driver: broker` when the authorized plan should continue after client disconnection. `caller` requires subsequent waits to advance stages. Both retain the original operation identity and stop before admitting new stages when a child outcome is uncertain. Changes to grants or contract compatibility can stop later stages while original receipts remain recoverable.

Each child input omits work/revision fields supplied by its scope. Use the documented typed output-reference shape only for earlier completed results; do not reconstruct a key by guessing its generated value. Per-stage limits, native execution budgets and accumulated result limits still apply to a single outer request.

Recover or cancel the parent with `atlas_operation`. Inspect committed stages and current revisions before planning further work. Atomic child readbacks can be labelled `provisional_group_state`; a rolled-back group's provisional IDs and values are not the current model. Running cancellation remains pending until Revit reaches its cooperative boundary. A terminal cancellation before execution means the queued request never started.

Historical Family batches remain recoverable through `atlas_operation`. Their steps committed separately, so recovery must not promise a group rollback. New v2 work uses admitted Core plans. There is no requirement to split a supported compound create-and-bind action into a plan.
