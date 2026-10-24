# Context-minimization policy

Apply this policy only when the module is enabled and `context_minimization` is `true`. Give each new request a fresh, isolated context; reuse a role thread only for clarification or unwinding within that same request. Use `fork_turns: none` where the host supports it, and record the actual mechanism and any host limitation in handoff metadata.

Keep handoffs to roughly 250-400 words and responses to roughly 300 words. Traceability, gates, identifiers, and material evidence take priority over those soft budgets.
