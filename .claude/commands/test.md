# /test

Unplanned verification work: reproduce a bug, or backfill missing coverage.

- The test artifact is an in-engine validation scenario. Never a unit test
  (D1).
- Bug fixing is reproduce-first: log it in bugs.md (`B-<n>`), write the
  scenario that fails the way the bug fails, then fix. The scenario is the
  regression guard; the bugs.md entry closes with one line pointing at it.
- Backfilled coverage still proves RED: neuter the behavior temporarily and
  watch the scenario fail before trusting it.
- A fixed bug with no scenario is a coverage gap, not tidying (bugs.md rules).
