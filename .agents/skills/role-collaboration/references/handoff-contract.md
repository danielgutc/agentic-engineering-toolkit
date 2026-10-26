# Coordinator handoff contract

Use this contract only while the module is enabled. Keep handoffs concise enough for the next owner to act without a duplicated transcript. Do not omit request IDs, parent IDs, status, approval gates, or material evidence.

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
Metadata: <mode, mechanism, status>
```

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

The coordinator owns all routing. At an approval gate, it presents conclusions, evidence, risks, and the deliverable to the user and waits. On an answer, it returns the concise result to the requester; on clarification, it resumes that same thread; on consultation, it creates one child with the original request as parent and increments depth. Do not create a child to a role already in the active path. Default limits are two nested levels and two clarification rounds.

Use exactly one response status. Conditional response fields apply only to their matching status. Never infer the reported model from the requested model or a profile setting. A child answer is evidence, never phase approval; relay it to the immediate parent and resume the same requester thread. On `blocked`, unwind the missing evidence, decision owner, or approval to that requester.

Keep one active child consultation per request. Allow at most two nested levels unless the user approves more, and at most two clarification rounds; then return `blocked`. If a proposed child role is already in the active request path, resume its existing thread instead of creating a cycle.
