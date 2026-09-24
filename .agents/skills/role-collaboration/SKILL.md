---
name: role-collaboration
description: Coordinate bounded, chained conversations between engineering roles through one root coordinator. Use when a role needs specialist input, a clarification exchange, or a nested consultation. Do not use for routine handoffs, broad parallel reviews, or direct peer-to-peer conversations.
---

# Role Collaboration

Use the root coordinator as the only communication hub. Each individual exchange remains one-to-one, but a specialist may request a nested consultation or ask the requester a clarification question. The coordinator routes every message, resumes existing role threads, and unwinds completed answers to the original requester.

## Message Contract

The coordinator creates each request. `depth` counts nested consultations from the original role request; start at `0` and increment it for each child request.

```text
ROLE REQUEST
Request ID: <stable identifier>
Parent request ID: <identifier or none>
Depth: <number>
From: <requesting role>
To: <specialist role>
Return to: <requesting role>
Question: <one bounded question>
Context: <only relevant facts and artifact identifiers>
Constraints: <boundaries, approvals, and fixed decisions>
Expected output: <specific recommendation, evidence, or review>
```

The specialist replies to the coordinator with exactly one status. Omit fields that do not apply.

```text
ROLE RESPONSE
Request ID: <matching identifier>
From: <specialist role>
Status: answered | clarification_needed | consultation_needed | blocked
Conclusion: <direct answer when answered>
Evidence: <facts, tradeoffs, or validation>
Impact: <what the requester should change or preserve>
Question: <clarification question when clarification_needed>
Consult role: <next specialist when consultation_needed>
Consult question: <one bounded child question>
Risks or assumptions: <material items>
Owner action: <decision, approval, or follow-up still required>
```

## Coordinator Flow

1. Route the request to one specialist and retain its thread as the active request thread.
2. On `answered`, send a concise response summary to `Return to`. If the request has a parent, resume the parent specialist thread; otherwise integrate the answer into the root work.
3. On `clarification_needed`, route the question to `Return to`, then send the reply back to the same specialist thread. This forms a bounded conversation without transferring ownership.
4. On `consultation_needed`, create one child request using the current request as `Parent request ID`, increment `Depth`, and route it to `Consult role`. When answered, resume the parent specialist thread with the child conclusion and evidence.
5. On `blocked`, unwind the block to the original requester with the missing evidence, decision owner, or approval required.

## Controls

- Keep one active child consultation per request. Parallel work is a separate orchestration choice, not this pattern.
- Allow at most two nested consultation levels by default. Ask the user before exceeding that limit.
- Allow at most two clarification round trips per request. Then return `blocked` with the unresolved question.
- Do not create a child request to a role already present in the active request path. Resume that role's existing thread with a clarification instead.
- Route summaries and artifact references, not full transcripts or duplicated documents.
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
