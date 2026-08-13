# /merge

Land the branch on main, fast-forward only.

- Pre-flight: clean tree, /ship said GO, main freshly fetched.
- `git switch main && git merge --ff-only <branch> && git push origin main`
- Delete with `git branch -d` (not `-D`): it refuses to delete anything
  unmerged, which makes it a second check that the merge actually landed.
- Know what the push triggers before you push: `.github/workflows/deploy.yml`
  is the authority on what deploys when. Say it out loud when you ask for
  the go-ahead.
- The phase ticket (`tasks/phase-<N>.md`) is deleted when the phase closes —
  which is not necessarily the moment the branch merges; a branch can carry
  several phases.
