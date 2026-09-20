---
name: use-atlas-core
description: Operate Atlas Core sessions, work items, inspection, intent, review, recovery and delivery. Pair with Atlas Family for native loadable-family authoring; standalone project operations have their own declared scope.
---

# Atlas Core

If tools cannot connect or the user requests setup, read [agent-assisted installation](references/installation.md). Use the packaged diagnostic/install helper yourself when setup is authorized; it works before MCP connects. Never ask the user to paste a token or troubleshoot by writing engine records.

This is the scoped Atlas public beta for Revit 2025 and 2026. Check `atlas_status` before execution. Discover live session identities; never reuse an identity from a previous task. Multiple Revit processes require an explicit session. Source, broker package and loaded engine versions are separate; an unavailable engine service requires its qualified binary, not a different tool spelling.

Core owns sessions, work identity, intent, inspection, review, recovery and delivery coordination. Family supplies family-specific operations through the paired connection. A shared credential means shared ownership; separate worker credentials remain isolated.

For a short or underspecified brief, state the size/source/detail assumptions you choose and what will be demonstrated. Ask only questions that materially change the result. A generic model is not a certified product. Do not weaken an explicit requirement.

Request one action's contract with `atlas_catalog` when its inputs are unfamiliar. For related operations, request one named workflow to receive their complete factored schemas together. For a nested choice, request its schema path and variant. Reuse returned contracts. The current connection and loaded engine determine admitted capabilities: `MIGRATION_PENDING` means the action cannot execute on this candidate. Retain the requirement as incomplete rather than working around it with scripts or historical tools.

Use `atlas_catalog` for installation-local family/project templates, starters and recipes. Recover a pending catalog operation with `atlas_operation`; its original filter and page survive restart. Starter availability does not establish acceptance of the requested family.

For standalone project work, create/open with `document_kind: project`. Omit it for families. Subsequent calls infer document kind from owned work. Read the action help's `standalone_project` applicability. Project inspection covers summary, paginated category-bearing elements and Project Information parameters; its values are formatted display text. Pages must have the same revision before combining them. Worksharing/cloud and general project/data editing remain unavailable. The separate Sheets/Annotations plugins adds drawing operations and read-only first-level local RVT links only when its matching native services are admitted. Do not infer those capabilities from the older private profile.

The admitted connection can define standalone project criteria for geometry, placed-instance type, documentation, visual judgment and warnings. Use project key `primary`, and review context `{kind: project, project: primary}`. Do not invent a family criterion or family coverage goal for an RVT. Bind discovered element keys, compile and validate. `atlas_review.record` records an observed image. Complete delivery with `projects: []`; the primary RVT is already owned. A missing review yields a capture request and continuation of the same delivery. Follow the exact current revision; save/reopen verification is mandatory.

`atlas_work.import_saved` copies a closed, clean saved family work item into a new identity. Supply its source manifest path and exact hash. Originals and historical signatures remain archived; old acceptance, bindings and images do not become new acceptance. Inspect identities, bind retained criteria, resume and reload owned project copies where required, then capture, judge and deliver fresh evidence.

Use a disposable work item for qualification. Preserve operation identities after timeouts and recover the original outcome with `atlas_operation`. Unknown is not failure or permission to replay. Supply the current expected revision when changing a model.

Use exact work/action grants for another connection; an inspection grant cannot close or edit work. Grants do not transfer ownership. A retry of an old grant operation retrieves its original receipt and cannot undo later revocation.

Large results have a retained response hash and a pagination request. Read those pages instead of repeating model operations. Guided review retains one parent operation through preparation and capture; inspect observes it, while wait can advance its next stage. Delivered image bytes require visual judgment and a native review record. Native operation success, saved files and original-brief acceptance are separate results; stale or reduced-scope evidence cannot establish completion. Acceptance is specific to the requested work and recorded evidence. The broad production matrix and the full smaller-model benchmark remain separate, incomplete gates; this beta is not a claim of universal family support.

When Sheets or Annotations is selected, use its skill and [drawing workflow](references/drawing-workflow.md). Core still owns the one work item and all evidence; a documentation work item does not need Family.

For uncertain results or review errors, read [review and recovery](references/review-recovery.md). Use `atlas_status.activity` with a task-start `since_utc` to measure this connection's external MCP calls and time; work filtering excludes unassigned discovery. Shared credentials share counts; provider time is not measured.
