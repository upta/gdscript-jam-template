# /build

The default working command: take the next unchecked task in `tasks/todo.md`
and land it. "Build the next phase" while the previous phase still has
unchecked engineering tasks means surface those instead.

- The Definition of Done in CLAUDE.md is the contract; meet it, don't restate
  it.
- Scenario first, confirm it FAILS (validate-gameplay skill), then implement
  to green, then `./validate.ps1`, then look at the screenshots.
- A contested call made along the way goes to DECISIONS.md in the same commit.
- Run the import so `.uid` sidecars exist; commit them with the change.
- Check the task off in todo.md: `✅ <date> (<one-line outcome>)`.
- Commit conventionally, in value language — what the player or the repo
  gained, not which files changed. Push at the end of the batch.
- End with **Try it**: how a human sees this change as a player
  (`./test-run.ps1`, then what to do in-game). If the change has no
  player-visible surface, say so rather than inventing one.
