# Decisions

Contested calls the code cannot explain itself. A decision belongs here only
if the choice was genuinely contested AND the code cannot self-document it —
bold title, three lines maximum, optional *Why:*. Ids are frozen: never
renumber, never reuse. New decisions append to Active; superseded ones move to
Closed as one-line stubs.

## Active

**D1 — Validation scenarios are the test suite; there is no unit-test framework.**
The test artifact is an in-engine scenario with numeric asserts and screenshot
checkpoints, run by `./validate.ps1`.
*Why:* an agent can prove behavior in the running engine and a human can audit
the screenshots; GUT/gdUnit4 were considered and rejected as a second, weaker
source of truth.

**D2 — Provider DI over autoload singletons.**
Services and state are provided down the tree, not registered globally.
*Why:* scoping — the game provides its InteractionService, a harness provides
its own, and test mode never builds the app stack. Autoloads would leak one
world into the other.

**D3 — GUIDE over Godot's InputMap.**
All gameplay input flows through GUIDE actions and contexts (`.tres`).
*Why:* per-screen contexts, kbm/controller switching, and input-glyph
formatting for prompts. Accepted cost: GUIDE reads devices, so validation
bridges InputMap presses into injected device events.

**D4 — GL Compatibility as the project renderer, everywhere.**
*Why:* web export forces gl_compatibility; running it in the editor means
developing on the renderer we ship instead of discovering differences after
export.

**D5 — The validation kit is a submodule + symlinks, not a vendored copy.**
`submodules/agentic_godot_validation`, materialized by setup.ps1 / setup.sh.
*Why:* kit improvements flow across projects, and GitHub template generation
verifiably preserves the gitlink (trail-and-error's initial commit carries it).

**D6 — Harnesses own probe position; buttons go through real GUIDE.**
Scenario input drives InputMap actions; harnesses bridge button edges into
`GUIDE.inject_input` and move the probe directly.
*Why:* GUIDE polls the OS cursor for mouse position — no injected event can
fake it, and warping loses to a physical mouse. Substituting the position
source keeps everything else on its real path.

**D7 — Deploys are tag-driven; pushing main deploys nothing.**
`v*` tags (or a manual workflow run) run the itch.io pipeline; CI on main is
compile + lint only.
*Why:* a jam-crunch push to main should never silently replace the live
build. Tagging is the deliberate act, and /merge says out loud what a push
triggers.

**D8 — Branch playtest builds cover every branch, main included, uploading
to Cloudflare R2 under `<repo>/<branch>/`.**
`playtest.yml` triggers on every branch push (not tag pushes). R2 rather
than Cloudflare Pages: Pages caps files at 25 MiB and a stock Godot 4 web
wasm is ~38 MiB.
*Why:* a maintainer wants a throwaway preview of main same as any other
branch. itch.io release (D7) is a separate concern, untouched by which
branches get a playtest prefix.

## Closed
