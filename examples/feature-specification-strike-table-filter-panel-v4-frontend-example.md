# Feature Specification: Strike Table Filter Panel

---
**Guideline Used**: `frontend-feature-specification-guidelines.md`
**Domain**: Frontend (React / TypeScript)
**Framework Version**: v4.0.0 — Agent-Era Update
**Status**: Reference example (illustrative, not shipped)
---

> **Purpose of this example.** A deliberately realistic frontend PRD demonstrating the v4.0.0 shape: `[Backend]` / `[Frontend]` prefixed functional requirements, an explicit spanning-requirement split (backend computes filters, frontend renders them), a populated Agent Execution Plan, Delegatable Research hoisted to Explore subagents, and references to `WORKFLOW.md` instead of restated rules. Also demonstrates the Final Audit checkpoint being satisfied before the PRD is considered done. The feature is plausible but fictional.

## Overview

The options strike table currently shows every strike for the selected expiration. Traders who have configured a maximum budget want the table to default to strikes they can actually afford, with a clear toggle to reveal the unaffordable ones. This PRD adds a filter panel above the strike table that composes three filters — budget, liquidity, and delta — and routes the filter state to the backend so the server returns only the rows the user will actually see. No filtering happens on the client except for the "reveal unaffordable" toggle, which operates on data the server has already marked.

## Goals

- Traders with a configured budget see only actionable strikes by default.
- Filter changes are reflected in the visible rows within 300 ms of the last filter interaction.
- The response shape supports future clients (mobile, API consumers) without reshaping data on the client.
- Zero regressions in the existing strike-table rendering performance.

## User Stories

1. As a budget-constrained trader, when I open the strike table for a symbol, I want unaffordable strikes hidden by default so I am not tempted to click into something I cannot execute.
2. As an experienced trader, I want a one-click "show all strikes" toggle that reveals the hidden rows so I can still see the full chain when I need it.
3. As a trader tuning liquidity tolerance, I want the filter panel to remember my last-used thresholds within the session so I am not reconfiguring on every symbol switch.

## Architectural Decisions

**Backend work.**
- The existing `GET /options/{symbol}/chain` endpoint already accepts query parameters for expiration and symbol. Extend it to accept `maxBudget`, `minOpenInterest`, and `deltaRange` as optional query parameters.
- Server-side filtering is authoritative. The server applies the filters to the chain it reads from the upstream market data provider and returns only the matching rows, each annotated with an `affordable: boolean` field so the frontend can render the "reveal unaffordable" state without a second call.
- No new endpoint. No new table. No new cache tier.

**Frontend work.**
- New `StrikeTableFilterPanel` React component above the existing `StrikeTable`.
- New `useStrikeFilters` hook that holds filter state in session-scoped React context (not `localStorage` — session-only per the acceptance criteria).
- On filter change, the component debounces (250 ms) then calls the extended chain endpoint with the current filter state as query parameters.
- The "reveal unaffordable" toggle is the only client-side filter: it flips a boolean that re-renders the `affordable=false` rows; it does **not** call the server again.

**Justification.** The filters themselves are backend work because (1) the result set is derived from server-owned data the client does not hold, (2) a future mobile client will want the same filtered response, and (3) keeping the filter logic server-side means a single authoritative source of truth for "is this strike actionable." The reveal toggle is frontend work because it operates on already-fetched data and is purely a UI preference.

## Functional Requirements

### Spanning requirement — correctly split

The original user story ("hide unaffordable strikes") touches both layers. Per `guidelines/frontend-feature-specification-guidelines.md` §2 Spanning Requirements, it is split into per-layer FRs, not left as one `[Both]` requirement.

- **FR1: Backend**: `GET /options/{symbol}/chain` accepts optional query parameters `maxBudget` (integer, USD), `minOpenInterest` (integer), and `deltaRange` (string, format `"min:max"` with decimal values in `[-1.0, 1.0]`) and applies them server-side before returning.
- **FR2: Backend**: When `maxBudget` is present, each returned row includes `affordable: boolean` computed as `askPrice * contractSize <= maxBudget`. When `maxBudget` is absent, the field is omitted entirely (not set to `null`).
- **FR3: Backend**: Unknown query parameters are ignored, not rejected, for forward compatibility with future filter fields.
- **FR4: Backend**: For an invalid `deltaRange` format, the endpoint returns HTTP 422 with body `{error: "INVALID_DELTA_RANGE", message: string, requestId: string}`. Matches the existing error envelope in `shared/errors.cjs`.

### Frontend-only requirements

- **FR5: Frontend**: `StrikeTableFilterPanel` renders three controls: a numeric input for `maxBudget` (USD), a numeric input for `minOpenInterest`, and a pair of numeric inputs for `deltaRange` low and high. It has `role="group"` with `aria-label="Strike table filters"`.
- **FR6: Frontend**: Filter state changes debounce at 250 ms, after which the component calls the chain endpoint with the current filter state as query parameters.
- **FR7: Frontend**: Filter state lives in session-scoped React context (no `localStorage`) and resets on full page reload.
- **FR8: Frontend**: When the response contains rows with `affordable=false`, the component renders those rows hidden by default and shows a status line above the table reading `"{n} strikes hidden (budget)"` with an accessible toggle button `"Show hidden strikes"`.
- **FR9: Frontend**: Clicking the toggle button flips the hidden/shown state of the `affordable=false` rows and does **not** trigger a new network call.
- **FR10: Frontend**: Every interactive control is reachable by keyboard with visible focus, and every control is labelled per WCAG AA.
- **FR11: Frontend**: On a 422 response from FR4, the component shows a visible error banner with the server's `message` and does not replace the last successful rows.

## Non-Goals

- No persistence of filter state across sessions (no `localStorage`, no server-side user preferences).
- No cross-expiration filtering — filters apply to the currently selected expiration only.
- No saved filter presets.
- No client-side filtering beyond the reveal toggle.
- No mobile-specific layout. This PRD targets the existing desktop breakpoint; a mobile layout is a separate PRD.

## Design Considerations

- Filter panel docks above the strike table, full width, matching the existing dashboard container padding.
- The reveal toggle is styled as a secondary button per the existing design system (`Button variant="secondary"`).
- Hidden-strikes status line uses the existing `<Status>` component with `tone="info"`.
- Focus management: after a filter change, focus stays on the control the user interacted with (no focus jumping).

## Technical Considerations

- **React version**: Existing app uses React 18 with TypeScript strict mode.
- **State management**: Session-scoped context provider wrapping the chain view; no Redux, no Zustand.
- **Network**: Reuse the existing `chainClient.fetchChain()` function; extend its type signature to accept the new optional parameters.
- **Test framework**: Vitest + React Testing Library per `WORKFLOW.md`.

## Failure & Recovery Strategy

- On network error during filter change: show a non-blocking toast, keep the last successful rows visible, and re-enable the retry path. Do not clear the table.
- On 422 from an invalid `deltaRange`: show an inline error on the delta range input, roll the input back to the last valid value, and do not call the server until the user provides a valid value.
- On 500 from the chain endpoint: show an error banner, leave the table in its last-successful state, and log the `requestId` to the error boundary's reporting sink.

## Testing Considerations

- Filter panel renders with every control labelled, keyboard-reachable, and WCAG-AA compliant (verify with `jest-axe`).
- Filter debounce: rapid changes within 250 ms result in exactly one network call.
- Reveal toggle flips row visibility without a new network call (verify by asserting `fetch` was called exactly once during the test).
- Server returns `affordable=false` rows: status line shows the correct count; clicking the toggle reveals the hidden rows.
- Invalid `deltaRange` input: server returns 422; component shows inline error; table rows unchanged.
- Filter state resets on full page reload.
- Edge case: zero-row response shows "No strikes match your filters" with no crash.

## Agent Execution Plan (v4.0.0)

- **Branch**: `feature/strike-table-filter-panel`
- **Workspace**: Standard feature branch.
- **Workflow policy**: See `WORKFLOW.md` at the repository root for test commands, branch policy, commit style, and hooks. Do not restate.
- **Required hooks**:
  - `PreToolUse(Bash:git commit)` runs Vitest and the lint gate via `pre-commit-gate.bash`.
  - `Stop` runs `verify-archival.bash`.

### Delegatable Research

- [ ] **Explore subagent**: Audit every file under `src/components/strike-table/` and report (a) the existing `StrikeTable` prop signature, (b) how row rendering currently handles optional fields, and (c) which hooks already exist for chain data fetching. Goal: avoid duplicating an existing hook; reuse where possible.
- [ ] **Explore subagent**: Search the codebase for existing usages of `jest-axe` and `role="group"` to confirm the accessibility pattern matches house style. Goal: consistent accessibility conventions across components.
- [ ] **Plan subagent**: Given the decision to keep filter state session-scoped (no `localStorage`), review whether the existing React context pattern already used by `src/context/chain-view-context.tsx` is the right wrapper or whether a new context should be introduced. Goal: independent second opinion on state placement.

## Success Metrics

- Filter interaction to visible row update: under 300 ms (measured by the existing `interaction-latency` test harness).
- Zero client-side filtering of `affordable=true` rows (verified by `tests/unit/strike-table-filter-panel.test.tsx` asserting no array filtering in the render path).
- Zero accessibility violations from `jest-axe` on the filter panel.
- Filter state reset on reload (verified by a full-page-reload integration test).

## Open Questions

None at PRD finalization time. The Plan subagent's context-placement recommendation, once received, will be folded into the implementation tasks and this section deleted.

---

## Final Audit — satisfied

This section is usually not part of the PRD itself — it is the checklist the agent runs against the PRD before presenting it. It is included here once, in this reference example, to demonstrate how the Final Audit in `guidelines/frontend-feature-specification-guidelines.md` §5 maps onto a real PRD.

**Architectural placement**
- ☒ Every functional requirement has a `[Backend]` or `[Frontend]` prefix — no spanning `[Both]` requirements.
- ☒ Filtering, affordability computation, and schema projection are on the backend. The frontend only renders and toggles.
- ☒ Every backend FR references the existing error envelope in `shared/errors.cjs`.
- ☒ The response shape (rows with `affordable: boolean`) works for a future mobile client without reshaping.
- ☒ No new endpoint invented — the existing chain endpoint is extended.
- ☒ No streaming or audit requirements — nothing to route to the System guideline.

**Agent execution plan**
- ☒ Branch name specified.
- ☒ Delegatable Research broken out for two Explore subagents and one Plan subagent.
- ☒ Required hooks named (`pre-commit-gate.bash`, `verify-archival.bash`).
- ☒ PRD references `WORKFLOW.md` instead of restating test commands, commit style, or branch policy.
- ☒ Every acceptance criterion is machine-verifiable (counts, latencies, assertion statements).

**Red flags — none apply**
- No `"frontend calculates"`, no `"frontend aggregates"`, no `"frontend normalizes"`.
- No sequential-hydration pattern (the frontend makes one call per filter change, not three).
- No audit or compliance-relevant operations assigned to frontend.
- No streaming transport specified in a frontend PRD.
- No prose rules the agent must "remember" — everything deterministic is in a hook.
- No restated `WORKFLOW.md` content inline.
- No flat sequential task list that could be parallelized — recon is in Delegatable Research, implementation is split backend/frontend.
