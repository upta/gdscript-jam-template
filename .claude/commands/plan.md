# /plan

Write the next phase ticket. Read-only for the codebase — no code changes.

- One file: `tasks/phase-<N>.md`, ~40 lines. One phase in flight at a time —
  a second `phase-*.md` is an error the docs hook enforces.
- Every task is a vertical slice a player can feel. A task that only adds a
  resource, a service, or a data structure is not a slice.
- Acceptance = named validation scenarios: what each drives, what it asserts,
  and what would prove it RED. If you cannot name the scenario, the task is
  not planned yet.
- Format:

```markdown
# Phase <N> — <name>
**Goal:** <2-3 sentences>

## Task <N>.1 — <name>
<1-2 sentences.>
- Acceptance: `<scenario_name>` — <drives / asserts / what proves it RED>
- Files: <the seams this touches (ARCHITECTURE.md names them)>

## Checkpoint <N> (HUMAN)
- [ ] <the feel question a human plays to answer>
```

- Reset `tasks/todo.md` to the new checklist; the final item is the human
  checkpoint.
- Stop for approval before /build.
