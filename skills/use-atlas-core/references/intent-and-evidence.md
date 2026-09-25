# Intent, coverage and useful results

Use create/open → define intent → build/edit → bind selectors → compile → validate/review → deliver. Intent records the original engineering request and all amendments; never edit engine records. Discover exact contracts for actions you do not know.

Coverage goals impose evidence across **every declared family type**:

| Goal | Required evidence |
|---|---|
| physical_dimensions | Component or circular-opening measurement for each type; parameter values and volume alone are insufficient. |
| type_flex | Restoring behavior probe measuring the requested size or position for each type. |
| nested_options | Native component-type selection checks for each type. |
| instance_controls | Restoring project-control probes on two distinct placed instances, for every type. |
| independent_materials | Material behavior probes with independence enabled and separate comparison components, for every type. |

Use goals applicable to the brief. No universal connector or solid-volume requirement. A single dimension check does not prove every requested dimension; declare each required behavior. Project work uses project criteria, not family coverage goals.

Adding new criteria retains the original brief. The usability candidate also recognizes added behavior types/samples when all previous values survive unchanged, tighter explicit tolerances in the same units, and stronger warning/association limits. Changing expected dimensions, removing coverage, or unknown equivalence remains a scope change. An exact family type list is exact: adding a type changes that assertion. Choose `type_match: contains` only when extra types genuinely satisfy the brief. Historical signed records are not rewritten; submit a reasoned amendment and obtain fresh evidence.

`atlas_requirements.inspect` reports bindings and coverage gaps, not proof of correct geometry. Compile produces the task key. `atlas_validate.run` tests that key against native state; inspect retained validation to understand failed or incomplete checks. Saved-and-verified files, declared checks and original-brief acceptance are separate gates. `ORIGINAL_SCOPE_NOT_ACCEPTED` requires resolving the retained scope difference; repeated saves do not fix it.

Family delivery also requires an explicit visual criterion, bound to a review view and relevant targets, with a recorded judgment of actual captured pixels. Include it before starting completion. Dimensions and behavior remain separate measured checks; an image alone does not establish them.

Large results retain the complete response by hash. Compact previews are selected fields, not full evidence. If the preview answers the immediate inspection question, continue without downloading unrelated details. Otherwise use the returned `next_request` or `details_request` with `atlas_inspect`, action `response`, and `input: {sha256, offset: 0, limit: 16000}`. Follow the returned `next_offset` until null; do not rerun the native operation to obtain its output.

For measured family flexing, select the required components with `atlas_inspect.measure`'s `targets` and requested `types`; retain the returned revision and restoration status. Check bounds/centers separately when the brief specifies centering, insertion origin or alignment. A distance constraint may move one end while preserving the requested size.
