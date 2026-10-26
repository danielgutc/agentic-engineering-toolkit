---
name: role-collaboration
description: Coordinate bounded role handoffs and specialist consultations through a root coordinator when its module is enabled. Do not use for direct peer-to-peer conversations or when the optional module is disabled or absent.
---

# Role Collaboration

This optional module is active only when its adjacent `config.json` is valid and `enabled` is `true`. A missing, invalid, or disabled configuration leaves ordinary coordinator routing and approval rules in place without this protocol. `context_minimization` independently controls the context-isolation policy; when false, retain the contract but omit that policy.

The root coordinator is the communication hub. It creates requests, retains ownership boundaries, and returns concise results to the requester. Read [the handoff contract](references/handoff-contract.md) before using the enabled protocol. Only when `context_minimization` is `true`, also read [the context policy](references/context-minimization.md). Discovery metadata can remain visible until the module is removed or a new host session starts.
