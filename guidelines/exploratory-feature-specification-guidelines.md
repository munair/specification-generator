# Freeform Specification Generator

This document is for **exploration, ideation, and creative overflow** before snapping back into a formal feature specification.  
It is intentionally loose. Use it to let the agent (or the human writer) **wander the playground** before the fence goes up.

---

## 0. Agent-Era Exploration Model (v4.0.0)
Exploration is no longer a pure thought exercise. A tool-using agent can **actually look around** before imagining solutions. Before answering any prompt below, the agent should:
1. **Delegate an Explore subagent.** Spawn an Explore subagent with a bounded question like *"What does the current options chain ingestion flow look like, and where are the seams where a new indicator could be inserted?"* Let it range across the repository while the main agent preserves context for creative work.
2. **Run cheap experiments.** If an idea is testable in under 30 seconds (hit an API, parse a file, run a one-liner), run it. Exploration used to be speculation; now it can be small, real measurements.
3. **Read adjacent prior art.** Grep the `examples/` and `documentation/specifications/completed/` directories for features that flirted with similar territory. Learn from what was tried.
4. **Summarize findings into §0.5 before opening §1.** Keep the creative context clean: 3–5 bullet points in the Recon Findings section below, nothing more.

Exploration is **broader** and **cheaper** than it was in v3.x — use subagents to expand breadth without losing focus.

---

## 0.5 Recon Findings (v4.0.0)

Paste the summarized output of Explore subagents here **before starting §1 The Spark**. Findings belong upstream of the creative sections so the agent knows what's already in the codebase, where the seams are, and which "bold" ideas are actually half-built. If a subagent reveals:

- **An adjacent feature already exists** — note the file path and the overlap, so §1 can pivot to augmentation instead of rebuild.
- **A hidden constraint** (existing data shape, auth model, perf budget) — note it as a fence rail for the playground.
- **A dead end** (tried before, abandoned, and why) — note it so §3 Failure Modes doesn't re-discover the same trap.

Keep it to bullets. If the findings run longer than five bullets, spawn another Explore subagent to filter rather than letting the recon crowd out imagination.

> **Intentionally before §1.** Section §0 instructs the agent to run recon first; the findings must therefore live before the creative sections, not after them. (In v4.0.0 earlier drafts this section was numbered §6.5 and placed at the end — that ordering contradicted §0 and has been corrected.)

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