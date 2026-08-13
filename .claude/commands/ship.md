# /ship

The phase gate. Three parts, in order.

**A — Review fan-out.** Spawn both reviewers
(`.claude/agents/code-reviewer.md`, `.claude/agents/test-engineer.md`) as
subagents IN ONE MESSAGE — sequential spawns lose the parallelism. Work their
Critical and Important findings.

**B — Verify the Definition of Done yourself.** Never on a subagent's word.
The suite re-run may be skipped only if the newest
`src/artifacts/suites/*/suite.json` is newer than every change under `src/`
(addons, artifacts, tools excluded) — and always re-run after Phase A
prompted a fix: a green suite from before the fix proves nothing about it.

**C — GO / NO-GO.** Report the verdict with evidence: suite result, boot
marker, which screenshots you reviewed and what they showed. NO-GO names
what's left.
