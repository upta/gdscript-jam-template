# CLAUDE.md

Game-jam template: GDScript, Godot 4.7.1, GL Compatibility, web export to
itch.io. Where things live and what words mean: ARCHITECTURE.md. Design
intent: SPEC.md. Contested calls: DECISIONS.md. This file is how we work.

## Truth hierarchy

When two sources disagree, the higher one wins and the lower one is a bug to
fix or delete:

1. **Code and validation scenarios** — what the game actually does
2. **ARCHITECTURE.md and this file** — where things live and how we work
3. **Active entries in DECISIONS.md** — contested calls the code can't explain
4. **Never: closed tasks or bugs.md.** The bug ledger is transient
   work-tracking that goes stale by design. Read it for leads, never as law;
   the scenario is the memory.

A doc that contradicts the code is a doc bug. Fix it or delete it — do not
annotate it as historical.

## Validation-first

Humans play-test for fun, feel, and design feedback. Proving the code works in
a running Godot engine is your job, before any human launches the game.

- A scenario that has never failed proves nothing. Confirm it goes RED before
  the implementation makes it green.
- A bug found in play-testing means validation had a gap: reproduce it in a
  scenario first, then fix.
- The mechanics live in the validate-gameplay skill; the kit's
  author-validation-scenario and debug-validation-failure skills carry the
  schema and the artifact-reading guide.

## Definition of Done

Stated once, here. Every command references it; none restate it.

1. **Scenarios exist** for the change — intended behavior, not just the happy
   path.
2. **They pass, and you looked at the screenshots.** Numeric assertions pass
   just fine while rendering is broken; the six-point rubric is in the
   validate-gameplay skill.
3. **Suite green** — `./validate.ps1`, no regressions.
4. **Game boots clean** — run-game skill: the positive marker appears and the
   runtime log has zero ERROR lines.
5. **Scripts compile and read clean** — `src/tools/check_scripts.ps1`; run
   `src/tools/lint.ps1` when gdtoolkit is installed.
6. **`.uid` sidecars committed** — run the import before committing; no
   unstaged `.uid` files left behind.
7. **Conventional commit in value language**, and `git push origin` at the end
   of every work batch.

## Planning and tasks

Work items are disposable. Documentation is not.

- `tasks/phase-<N>.md` is the one ticket for the phase in flight, ~40 lines.
  One phase at a time — a second `phase-*.md` is an error the docs hook
  enforces. Deleted when the phase closes, not archived.
- `tasks/todo.md` is the current checklist; the final unchecked item is always
  the human checkpoint (the feel question a human plays to answer).
- Ids are frozen. Task numbers, decision ids (`D<n>`), bug ids (`B-<n>`):
  never renumber, never reuse, never delete an id — a citation that resolves
  to nothing is a doc bug.

## Commands

| Command | Purpose |
| --- | --- |
| `/spec` | Interview-first design intent, folded into SPEC.md in place |
| `/plan` | Write the next phase ticket; read-only for code |
| `/build` | Land the next unchecked task; the default working command |
| `/test` | Unplanned verification: reproduce a bug, backfill coverage |
| `/review` | Cheap single-pass five-axis review, mid-phase |
| `/ship` | The phase gate: reviewers fan out, DoD verified, GO/NO-GO |
| `/merge` | Fast-forward-only landing on main |

## Boundaries

- **Ask first:** any change inside `submodules/agentic_godot_validation/`
  (the kit is shared across projects), adding addons, changing export presets.
- **Never:** edit `src/addons/**` (guide and provider are vendored; the
  validation addon is the submodule through a symlink); hand-author
  `uid://` values; delete or weaken a failing scenario to get the suite
  green; kill a running godot with Stop-Process — force-kill loses buffered
  output and a 0-byte log reads as a clean pass.
- **`tools/` is a symlink into the submodule** — it holds the kit's runners,
  not ours. Repo-owned scripts live in `src/tools/` or at the repo root.

## Known issues

- 4.7.1 editor-mode passes (`--import`, `--editor`) intermittently log
  `ERROR: Unrecognized UID: "uid://cdpvteme84tjq"` (root.tscn, the main
  scene), most often right after addon files change on disk. Editor startup
  race triggered by GUIDE 0.14.0's presence; exit codes stay 0 and runtime
  always resolves the scene. Runtime logs never show it — keep runtime-log
  gates fully strict, and do not add this to any runtime allowlist.

## Style

- Typed GDScript where the type is evident: `-> void`, `:=`, typed signal
  parameters. Two blank lines between functions.
- Comments only where the code can't say it — constraints and traps, not
  narration.
- Dictionaries: prefer typed (`Dictionary[String, int]`); prefer `.get()` /
  `.set()` over `[]`.
- `.uid` files are Godot-generated. Never create or edit one by hand.
- PowerShell scripts: UTF-8 **with BOM** (Windows PowerShell 5.1 misparses
  BOM-less UTF-8), and `Start-Process -Wait` for godot.exe — it is a
  GUI-subsystem binary, so a bare invocation returns immediately.
