---
name: use-atlas-core
description: Operate Atlas Core sessions, work items, inspection, intent, review, recovery and delivery. Pair with Atlas Family for native loadable-family authoring; standalone project operations have their own declared scope.
---

# Atlas Core

This is the scoped public v2 interface. Read [agent-assisted setup](references/installation.md) when it cannot connect. Core supplies a pinned setup helper for the matching shared runtime. Never paste credentials or edit admission records.

Check `atlas_status` and select the intended live session before execution. Multiple Revit processes require an explicit session. The installed package, loaded engine, Revit version, qualified scope and connection admission are separate facts. Discover identities again in a new task. Presence in a source catalog does not establish executable or qualified behavior. A dispatcher idle timestamp records a past observation; it does not mean the current native queue is free.

Core owns sessions, work identity, intent, inspection, review, recovery and delivery coordination. Family supplies family-specific operations through the paired connection. A shared credential means shared ownership; separate worker credentials remain isolated.

For a short or underspecified brief, state the size/source/detail assumptions you choose and what will be demonstrated. Ask only questions that materially change the result. A generic model is not a certified product. Do not weaken an explicit requirement.

Create/open the work item, define engineering intent with `atlas_requirements.define`, then author or edit. Criteria describe expectations before geometry exists; bindings later select real identities. For coverage goals, amendments and validation gates, read [intent and evidence](references/intent-and-evidence.md). A stronger check requires fresh bindings and validation; it does not inherit a previous pass.

Request one action's contract with `atlas_catalog` when its inputs are unfamiliar. For related operations, request a named workflow's factored schemas together; for a nested choice, request its schema path and variant. Reuse contracts while their digest is unchanged. `MIGRATION_PENDING` or a missing capability means that route is unavailable for this connection. A denied route does not grant authority through another tool.

Use typed actions for normal work. When admitted, `atlas_execute.run` groups a known sequence or consistent reads and retains one recoverable parent. Read [execution plans](references/execution-plans.md) when choosing transaction policy, output references or autonomous continuation. Core orchestration still checks each specialist action's grants and capabilities.

For unusual operations within an admitted family scope, Core provides checked `atlas_script.check/run`; read [checked scripting](references/checked-scripting.md). This requires its own host admission and declared effects. It shares normal ownership, revision, cancellation and evidence rules. The separate legacy RevitAtlas MCP is not an Atlas dependency or recovery path.

Use `atlas_catalog` for installation-local family/project templates, starters and recipes. Recover a pending catalog operation with `atlas_operation`; its original filter and page survive restart. Starter availability does not establish acceptance of the requested family.

For standalone project work, create/open with `document_kind: project`. Omit it for families. Subsequent calls infer document kind from owned work. Read the action help's `standalone_project` applicability. Project inspection covers summary, paginated category-bearing elements and Project Information parameters; its values are formatted display text. Pages must have the same revision before combining them. Worksharing/cloud and general project/data editing remain unavailable. The separate Sheets/Annotations plugins adds drawing operations and read-only first-level local RVT links only when its matching native services are admitted. Do not infer those capabilities from the older private profile.

The admitted connection can define standalone project criteria for geometry, placed-instance type, documentation, visual judgment and warnings. Use project key `primary`, and review context `{kind: project, project: primary}`. Do not invent a family criterion or family coverage goal for an RVT. Bind discovered element keys, compile and validate. `atlas_review.record` records an observed image. Complete delivery with `projects: []`; the primary RVT is already owned. A missing review yields a capture request and continuation of the same delivery. Follow the exact current revision; save/reopen verification is mandatory.

`atlas_work.import_saved` copies a closed, clean saved family work item into a new identity. Supply its source manifest path and exact hash. Originals and historical signatures remain archived; old acceptance, bindings and images do not become new acceptance. Inspect identities, bind retained criteria, resume and reload owned project copies where required, then capture, judge and deliver fresh evidence.

Use a disposable work item for qualification. Preserve operation identities after timeouts and recover the original outcome with `atlas_operation`. Unknown is not failure or permission to replay. Supply the current expected revision when changing a model.

Updated engines can hand a saved, clean, closed work item to another live Revit session using `resume`; the document lock, release marker and checkpoint hash protect ownership. Open work cannot transfer. A closed work item retained by an older engine may still require that original Revit session to exit normally. Inspect through the destination session first and use its reported revision; never repair ownership by editing manifests.

Use exact work/action grants for another connection; an inspection grant cannot close or edit work. Grants do not transfer ownership. A retry of an old grant operation retrieves its original receipt and cannot undo later revocation.

Large results have a retained response hash and a pagination request. Read those pages instead of repeating model operations. Guided review retains one parent operation through preparation and capture. If the loaded action contract offers `execution_driver: broker`, family-work preparation/capture can continue after client disconnect; use it for a review that should finish autonomously. Omission preserves caller-driven behavior: inspect observes, while wait can advance the next stage. Cancel the original parent to stop future stages; retain that identity after a timeout. Neither mode records a visual judgment. Delivered image bytes require visual judgment and a native review record. Native operation success, saved files and original-brief acceptance are separate results; stale or reduced-scope evidence cannot establish completion. Acceptance is specific to the requested work and recorded evidence. The broad production matrix and the full smaller-model benchmark remain separate, incomplete gates; this alpha is not a claim of universal family support.

When Sheets or Annotations is selected, use its skill and [drawing workflow](references/drawing-workflow.md). Core still owns the one work item and all evidence; a documentation work item does not need Family.

Delivery may finish an invocation at `awaiting_review` or `saved_requires_validation` while acceptance remains incomplete. Follow its next request and continue the same workflow after supplying the required evidence. A completed operation is not a completed delivery. Failed checks, changed original scope and interrupted native work retain their failure/recovery state; another save cannot replace a missing judgment.

For uncertain results or review errors, read [review and recovery](references/review-recovery.md). Use `atlas_status.activity` with a task-start `since_utc` to measure this connection's external MCP calls and time; work filtering excludes unassigned discovery. Shared credentials share counts; provider time is not measured.
