# Skill evaluation scenarios

Use these requests to evaluate changes to skill selection and task behavior. Run the relevant cases with a fresh agent and the candidate skills. Supply the request and raw artifacts without the expected outcome or prior review findings. Evaluate the response and any generated artifacts afterward; record the model reported by the host, the skill revision, evidence, and any limitations. If independent agents are unavailable, report that limitation rather than presenting self-review as an independent evaluation.

These are manual behavior checks, separate from `run.ps1`. Assess decisions and scope rather than exact headings, wording, response length, or number of steps. Keep generated fixtures in a temporary workspace and restrict the evaluation to those fixtures; external actions require their own authorization.

## Focused repository impact

Request: "In this unfamiliar repository, find where the invoice export filename is chosen and which test covers it. Return the relevant locations."

Artifacts: a small temporary repository with an export function, its calling CLI, a filename test, and unrelated documentation. Include realistic source names and applicable local instructions.

Expected evidence: selects repository assessment, traces the filename and test, and returns grounded locations. Broader lifecycle inventory is needed only if it helps answer the request.

## Architecture comparison

Request: "Compare keeping our existing in-process cache with adding a shared cache. We run one application instance today, tolerate losing cached data, and have no measured latency problem. Recommend whether to change it. This is decision advice; record any assumptions."

Artifacts: the architecture-decision skill and the stated context; no repository changes are needed.

Expected evidence: compares viable options using the supplied constraints and explains consequences and uncertainty. Qualitative priorities are sufficient; any numerical weights or targets need evidence.

## Chosen product direction

Request: "We have chosen an appointment reminder product for independent tutors. Help define an MVP and the assumptions to test. Preserve this product direction. We have interviewed two tutors who currently remind students manually; we have no evidence about willingness to pay."

Artifacts: the product-discovery skill and the stated interview summary.

Expected evidence: develops tutor outcomes, coherent MVP scope, and testable assumptions within the chosen direction; distinguishes interview evidence from untested demand. Leaves architecture to its owner.

## Requirements boundary

Request: "Our approved product direction is appointment reminders for tutors. Specify the observable behavior when a tutor reschedules a lesson after a reminder has been queued. The approved rule is that the old reminder must not be delivered and a reminder must use the updated time. Do not choose implementation technology."

Artifacts: discovery metadata for the project skills and the requirements-specification skill when selected.

Expected evidence: selects requirements specification and captures observable rescheduling and stale-reminder behavior. Keeps unresolved policy questions explicit without choosing queue or database technology.

## Review boundary

Request: "Review this filename change and report defects."

Artifacts: discovery metadata for the project skills and a temporary before/after diff that removes filename sanitization while leaving the output path joined to user input. Provide the surrounding export function and its tests.

Expected evidence: selects code review, traces the input to the output path, and explains any demonstrated regression with locations. Preserves the review-only scope.
