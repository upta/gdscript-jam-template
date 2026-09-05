---
name: architect
description: Runs while /outline drafts each task in a phase ticket. Name the seam the task uses (ARCHITECTURE.md § Seams); if none fits, state concretely how you intend to build it and stop for approval before the ticket is done.
---

# Architect

Most tasks fit one of ARCHITECTURE.md's seams. This skill exists so that when
a task does NOT fit, the new shape is stated and agreed before it lands,
instead of appearing in a diff.

## When

Runs while `/outline` drafts each task in a phase ticket, before the ticket
is stopped for approval: name the seam the task uses (ARCHITECTURE.md §
Seams). If it fits, say which one in one line and proceed — no proposal
needed. If it doesn't — a new service or state shape, a new contract, a new
addon, or any pattern the codebase doesn't already have, even in one file —
write the proposal below and stop.

Also use standalone when a task outside the /outline → /build flow (e.g.
/test) looks like it needs a seam the template does not have.

## The proposal (post it, then stop)

```markdown
## Proposal: <change>

**Problem.** <what cannot be expressed today, with the concrete feature or scenario that needs it>

**Seam.** <existing seam it extends, or the new seam, named the way ARCHITECTURE.md § Seams names them>

**Shape.**
- <type / method / field, with full signature and where it lives — path under src/>
- <who provides/injects it, when, and what the default does so existing screens are unaffected>
- <signals emitted, if any, with payload>

**Contracts touched.** <scenario JSON / harness protocol / GUIDE action-context convention / Config save format / none>

**Proof.** <the validation scenario that will show it RED then GREEN>

**Rejected.** <one or two alternatives and the sentence that kills each>

**Cost.** <files touched, scenarios added, ARCHITECTURE.md rows updated>
```

Then wait for explicit approval. Do not start the implementation in the same
turn, even "just the easy part".

## During implementation

- A *structural* deviation from the approved shape (a different seam, a
  different signature, a contract change not listed) means stop and re-propose
  that part.
- A *tactical* deviation (a helper, a rename, a default value) is logged as it
  happens and reported in an **Architecture deviations** section at the end of
  the turn, with one line each.
- The proposal's Proof section becomes the RED step of the validate-gameplay
  loop; if the proof changes, say so.
- If a decision was genuinely contested along the way, it goes in
  DECISIONS.md as a new `D<n>` (never renumber); ARCHITECTURE.md gets the
  resulting seam/vocabulary row once the change lands.
