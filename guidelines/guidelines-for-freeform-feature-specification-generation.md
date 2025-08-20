# Freeform Specification Generator

This document is for **exploration, ideation, and creative overflow** before snapping back into a formal feature specification.  
It is intentionally loose. Use it to let the AI (or the human writer) **wander the playground** before the fence goes up.

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

## 7. Feature Tagging Strategy

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