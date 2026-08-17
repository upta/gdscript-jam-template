# Architecture

Where things live and what the words mean. This file does not restate what
code does — follow the paths. If it contradicts the code, the code wins and
this file has a bug: fix it or delete it.

## Codemap

| Path | What lives here |
| --- | --- |
| `src/app/root/` | Composition root: `root.tscn` is the main scene; `root.gd` builds Config → State → Services, provides them, then starts `app.tscn` — or routes to the validation bootstrap under `--test-mode`. |
| `src/app/screen_manager/` | Swaps the active screen with an overlay transition; prints the `[App] Screen ready:` boot marker. |
| `src/app/service/` | Operations injected via Provider (GuideService, ScreenService). |
| `src/app/state/` | Observable state with signals (GuideState, ScreenState) — bookkeeping, not behavior. |
| `src/app/config/` | `Config`: `user://config.cfg` persistence. |
| `src/audio/` | AudioService/AudioState: SFX pool, music player, bus volumes persisted via Config. `audio.gd` catalogs streams. |
| `src/game/` | The demo game screen: two characters with health, driven by the interaction system. |
| `src/game/interaction/` | The interaction system (ported from trail-and-error): probe, targets, registrations, service, prompt. |
| `src/guide/` | GUIDE mapping contexts and actions as `.tres`, grouped per game mode (global / main_menu / game). |
| `src/main_menu/`, `src/settings/` | The other screens: menu, and the settings overlay with audio sliders. |
| `src/validation/` | The scenario suite: `scenarios/*.json`, `harnesses/*.tscn`, `scripts/harness_controllers/`. |
| `src/addons/guide/` | G.U.I.D.E, vendored — never edited here. |
| `src/addons/provider/` | Provider DI — owned upstream (upta/godot-provider), treat as vendored. |
| `src/addons/agentic_godot_validation/` | Validation kit runtime — a symlink into the submodule. |
| `src/tools/` | Repo-owned checks: `check_scripts.ps1` (compile gate, engine half in `compile_check.gd`), `lint.ps1`. |
| `.claude/` | The workflow machinery: skills, commands, reviewer agents, and the two blocking Stop hooks (validation freshness, doc budgets). CLAUDE.md is the contract. |
| repo root | `validate.ps1` (THE gate), `test-run.ps1` (dev loop), `setup.ps1`/`setup.sh` + `symlink-config.txt` (kit intake), `tools/` → kit runners (symlink). |

## Seams

- **Provider DI.** `Provider.provide(node, value)` in `_enter_tree`; `Provider.inject(self, Type)` in `@onready`. Lookup walks up the tree, so whoever provides scopes the dependency: root provides app-wide services, `game.gd` provides the InteractionService, a harness provides its own.
- **Screens.** `ScreenService.change_to_scene(scene)` → `ScreenState.active_path` → the screen manager loads, transitions, prints the marker. A screen is a plain scene under its own directory.
- **Input.** Actions are `.tres` resources referenced by `@export`; `GuideService.set_game_mode("…")` enables that mode's mapping contexts for the active device. GUIDE reads devices, not InputMap — anything synthetic must inject device events (see the interaction harness).
- **Interaction.** The owner (game.gd, or a harness) provides InteractionService and pumps it each physics frame with probe data. Targets register while the probe overlaps; the focused target wins its own key.
- **Test mode.** `--test-mode` in user args short-circuits `root.gd` into the kit's bootstrap; the app stack never builds. Harnesses provide whatever their scene injects.

## Golden path

The interaction demo is the exemplar vertical — pattern-match it:

1. Actions: `src/guide/game/actions/attack.tres`, `heal.tres`, `cursor.tres`
2. Bindings: `src/guide/game/game_kbm_context.tres` (LMB / RMB / mouse position)
3. The scene declares the hotspots: `src/game/character/character.tscn` — a labeled AttackTarget and a silent HealTarget, shapes authored in-scene
4. Behavior: `src/game/character/character.gd` creates the registrations (dynamic label, callbacks)
5. Wiring: `src/game/game.gd` provides the service and pumps the cursor probe
6. Feedback: `src/game/interaction/interact_prompt.tscn` renders the focused label and input glyph
7. Proof: `src/validation/harnesses/interaction_harness.tscn` mirrors 3–6 without the app stack; `src/validation/scenarios/*.json` drive it and assert with screenshots

## Vocabulary

| Noun | Meaning |
| --- | --- |
| screen | A top-level scene the screen manager swaps (main menu, game). |
| service | Operations injected via Provider (AudioService, ScreenService, InteractionService). |
| state | Observable data with signals (AudioState, GuideState, ScreenState). |
| action / context | GUIDE resources: an action is the game-facing input; a mapping context binds device inputs to actions per game mode. |
| target / probe / registration | Interaction nouns: a target is a hotspot, the probe is the reach, a registration is one interactable offer. |
| harness / scenario / artifact | Validation nouns: a minimal scene, the JSON contract that drives it, and the evidence a run writes. |

## Known shape problems

Named so nobody copies them as patterns:

- `settings_menu.gd` awaits a process frame before injecting SettingsManager — a creation-order patch, not a pattern. Needing it twice means fix the ordering instead.
- `GuideState.last_context_change_frame` is a mutable static, chosen so harnesses without a GuideService still resolve the trigger guard. Keep it the only one.
- The screen manager loads screens by string path (from `scene.resource_path`) at runtime — renames surface at runtime, not compile time. Confined to the screen seam; don't spread `load("res://…")` string paths into gameplay code.
