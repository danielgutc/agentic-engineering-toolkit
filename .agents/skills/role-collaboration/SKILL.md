---
name: role-collaboration
description: Coordinate bounded, chained conversations between engineering roles through one root coordinator. Use when a role needs specialist input, a clarification exchange, or a nested consultation. Do not use for routine handoffs, broad parallel reviews, or direct peer-to-peer conversations.
---

# Role Collaboration

Use the root coordinator as the only communication hub. Each individual exchange remains one-to-one, but a specialist may request a nested consultation or ask the requester a clarification question. The coordinator routes every message, resumes existing role threads, and unwinds completed answers to the original requester.

## Handoff Contract

The coordinator creates every role request and handoff. Keep it lightweight: send only the artifact summary needed by the next role, not a transcript or a duplicate of the artifacts. Include artifact identifiers or paths so the recipient can retrieve the source. Use `none` when a field does not apply; do not silently omit traceability fields. `depth` counts nested consultations from the original role request; start at `0` and increment it for each child request.

```text
ROLE HANDOFF
Request ID: <stable identifier>
Parent request ID: <identifier or none>
Depth: <number>
From: <requesting role>
To: <specialist role>
Return to: <requesting role>
Approved scope: <approved boundaries and exclusions>
Requirement IDs: <in-scope identifiers or none>
Prior role decisions: <relevant decisions and artifact references>
Open questions: <unresolved questions and their decision owners, or none>
Exact deliverable: <specific output and completion criteria>
Next owner: <role or user who owns the next decision or phase>
Relevant artifact summary: <only facts needed for this request, with artifact identifiers or paths>
Question: <one bounded question>
Constraints and approval gate: <fixed decisions, applicable gate, or none>
Requested model: <exact model requested, host default/no pin, or unavailable>
```

The specialist replies to the coordinator with exactly one status. Preserve request and parent request IDs at every depth, including in nested consultations. Report the actual model identifier only when the runtime or specialist can identify it; otherwise write `unavailable`. Never infer the reported model from the requested model.

```text
ROLE RESPONSE
Request ID: <matching identifier>
Parent request ID: <matching identifier or none>
From: <specialist role>
Status: answered | clarification_needed | consultation_needed | blocked
Conclusion: <direct answer when answered>
Evidence: <facts, artifact references, tradeoffs, or validation>
Risks or assumptions: <material items, or none>
Owner action: <next owner and the decision, approval, or follow-up required>
Reported model: <actual model identifier, or unavailable>
Question: <clarification question when clarification_needed>
Consult role: <next specialist when consultation_needed>
Consult question: <one bounded child question>
```

## Coordinator Flow

1. Route each transition through the coordinator and preserve the role's current ownership. Send the `ROLE HANDOFF` fields and only the relevant artifact summary to the next role.
2. At an approval gate, present the current role's conclusions, evidence, risks, and exact deliverable to the user, then pause and wait for approval before advancing. A specialist response is evidence, not approval.
3. On `answered`, send a concise response summary to `Return to`. If the request has a parent, resume that parent request; otherwise integrate the answer into the root work.
4. On `clarification_needed`, route the question to `Return to`, then send the reply back to the same specialist thread. This forms a bounded conversation without transferring ownership.
5. On `consultation_needed`, create one child request with the current `Request ID` as its `Parent request ID`, increment `Depth`, and retain the original request and return owner. When answered, relay the child's concise answer and evidence back to the original requesting role using the original request identifiers; do not advance the lifecycle on the child's authority.
6. On `blocked`, unwind the block to the original requester with the missing evidence, decision owner, or approval required.

## Controls

- Keep one active child consultation per request. Parallel work is a separate orchestration choice, not this pattern.
- Allow at most two nested consultation levels by default. Ask the user before exceeding that limit.
- Allow at most two clarification round trips per request. Then return `blocked` with the unresolved question.
- Do not create a child request to a role already present in the active request path. Resume that role's existing thread with a clarification instead.
- Route summaries and artifact references, not full transcripts or duplicated documents.
- Require every specialist response to include its conclusion, evidence, risks or assumptions, and owner action; record requested and reported models in separate fields for each role.
- A specialist stays within its abstraction and does not take ownership of the requester's decision.
- The coordinator resolves conflicting advice, records durable decisions, and preserves approval gates.
- Agent responses provide evidence, not user approval. Never infer lifecycle approval from a role response.
- Skip delegation when the active role already has sufficient evidence or owns the question.
- Close completed role threads after their response has been integrated and no follow-up remains.

## Common Routes

- Product owner to solutions architect: feasibility, quality-attribute implications, constraints, and architecture risk.
- Solutions architect to technical architect: implementability of an approved container direction or contract boundary.
- Technical architect to software engineer: implementation feasibility, framework behavior, tooling evidence, or a bounded spike.
- Technical architect to infrastructure engineer: build, packaging, runtime, or delivery feasibility.
- Software engineer to technical architect: ambiguous contracts, test seams, skeletons, or detected architecture drift.
- Test engineer to product owner: ambiguous acceptance intent.
- Test engineer to technical architect: ambiguous contracts or insufficient test seams.
- Any delivery role to infrastructure engineer: environment, pipeline, observability, or deployment evidence.
