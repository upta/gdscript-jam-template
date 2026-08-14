# /merge

Land the branch on main, fast-forward only.

- Pre-flight: clean tree, /ship said GO, main freshly fetched.
- `git switch main && git merge --ff-only <branch> && git push origin main`
- Delete with `git branch -d` (not `-D`): it refuses to delete anything
  unmerged, which makes it a second check that the merge actually landed.
- Delete the remote branch too — `git push origin --delete <branch>`. This is
  cleanup, not tidiness: the deletion is what fires
  `.github/workflows/playtest-cleanup.yml`, which prunes the branch's ~40 MiB
  playtest build from R2. Skip it and the objects stay in the bucket forever.
  Confirm the prune run went green before calling the merge done.
- Know what the push triggers before you push: `.github/workflows/deploy.yml`
  is the authority on what deploys when. Say it out loud when you ask for
  the go-ahead.
- The phase ticket (`tasks/phase-<N>.md`) is deleted when the phase closes —
  which is not necessarily the moment the branch merges; a branch can carry
  several phases.
