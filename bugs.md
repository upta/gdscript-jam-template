# Bugs

Play-test ledger — transient work-tracking, deliberately NOT a source of
truth (the scenario is the memory). Read it for leads, never as law.

Rules:

- Ids `B-<n>` are append-only and frozen; never renumber or reuse.
- Status: `open`, `fixed (<commit>)`, or `wontfix (<reason>)`.
- Every entry leaves by reaching a real home: a validation scenario
  (behavior), CLAUDE.md or a skill (a way of working), or the spec/plan.
  A fixed entry with no scenario is a coverage gap, not tidying.
- Closed entries compress to one line naming where the memory lives now.

## Open

_None._

## Closed

_None._
