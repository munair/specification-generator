# Freeform Specification Generator

This document is for **exploration, ideation, and creative overflow** before snapping back into a formal feature specification.  
It is intentionally loose. Use it to let the agent (or the human writer) **wander the playground** before the fence goes up.
---
## 0. Agent-Era Exploration Model (v4.0.0)
Exploration is no longer a pure thought exercise. A tool-using agent can **actually look around** before imagining solutions. Before answering any prompt below, the agent should:
1. **Delegate a reconnaissance subagent.** Spawn an Explore subagent with a bounded question like *"What does the current options chain ingestion flow look like, and where are the seams where a new indicator could be inserted?"* Let it range across the repository while the main agent preserves context for creative work.
2. **Run cheap experiments.** If an idea is testable in under 30 seconds (hit an API, parse a file, run a one-liner), run it. Exploration used to be speculation; now it can be small, real measurements.
3. **Read adjacent prior art.** Grep the `examples/` and `documentation/specifications/completed/` directories for features that flirted with similar territory. Learn from what was tried.
4. **Keep the creative context clean.** Do not let recon findings crowd out imagination. Summarize subagent findings into 3–5 bullet points before resuming the creative sections below.
Exploration is **broader** and **cheaper** than it was in v3.x — use subagents to expand breadth without losing focus.

---

## 1. The Spark

- What problem, frustration, or opportunity sparked this feature idea?  
- What excites you most about solving it?  
- What's the boldest possible version of this feature?  

---

## 2. The Dream Scenario

- If this feature wildly exceeded expectations, what would users say?  
- What's the most delightful, "wow" moment it could create?  
- How would it change the overall product or workflow?  

---

## 3. The Failure Mode

- If this feature went wrong, how could it fail spectacularly?  
- What's the worst confusion, risk, or misuse it could cause?  
- What would be wasted effort if it crept out of scope?  

---

## 4. The Metaphor

- Is there a metaphor or analogy that captures the essence of this feature?  
  *(e.g. "Fence and Playground," "Copilot Override," "Budget Guardrail")*  
- How does that metaphor guide design choices?  

---

## 5. Rough Sketch

*(Optional)*  
- Draw or describe the first mental picture that comes to mind.  
- No wrong answers — just imagery, layout, or flow.  

---

## 6. Notes Dump

- Any stray thoughts, side ideas, or "what-ifs" to capture now.  
- Even if they don't fit, record them here for later pruning.  

---

## 6.5 Recon Findings (v4.0.0)
Paste the summarized output of any Explore subagents here. Keep it short (bullets, not essays). These findings should inform — but not constrain — the creative sections above. If a subagent reveals that a wild idea is already half-built in the codebase, note it here and celebrate; if it reveals a hidden constraint, note that too.

---

## 7. Archival Cross-Reference

**IMPORTANT**: When archiving implementation logs, follow the **ARCHIVAL PROTOCOL** in `implementation-tasks-creation-guidelines.md`.

Key requirements:
1. Mark ALL tasks complete (`- [ ]` → `- [x]`)
2. Rename from `implementing-` to `implementation-log-`
3. Move to `documentation/tasks/completed/`

**DO NOT** attempt to archive without following the protocol checklist.

---

## 8. Feature Tagging Strategy

After implementation, tag the feature with a descriptive name that reflects the core solution:

### Tagging Guidelines:
- **Use the feature specification name**: `[feature-name]-[solution-approach]`
- **Be specific and searchable**: `persistent-display-css-grid-solution`
- **Include the technical approach**: `user-authentication-oauth2-integration`
- **Avoid generic version tags**: Use descriptive tags instead of `v1.2.3`

### Examples:
- `persistent-display-css-grid-solution` ✅
- `user-preferences-local-storage` ✅
- `real-time-notifications-websocket` ✅
- `v0.5.1` ❌ (too generic)

### When to Tag:
- After successful implementation and testing
- Before version bumps (which come after documentation updates)
- When the feature is production-ready

### Benefits:
- **Searchability**: Easy to find specific feature implementations
- **Documentation**: Tags serve as implementation markers
- **Technical History**: Preserves solution approaches over time
- **Team Communication**: Clear feature identification
- **Version Management**: Proper separation of concerns

---

> After freeform exploration, migrate the essentials into either:
> - `/templates/feature-specification-template-simple.md` for straightforward features  
> - `/templates/feature-specification-template-full.md` for complex, strategic features  
> Keep both documents: the freeform generator captures **breadth**, the PRD captures **focus**.