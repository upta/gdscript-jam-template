---
name: godot-scene-authoring
description: Use when creating or editing a .tscn/.tres, adding a scene script, binding child nodes, or adding a GUIDE action — text-format mechanics, uid rules, and the scene-first boundaries.
---

# Godot scene authoring

## .tscn text format

- Header: `[gd_scene load_steps=<N> format=3 uid="uid://…"]` where
  `load_steps = ext_resources + sub_resources + 1`. Recount after every edit —
  a wrong count corrupts the load.
- `[ext_resource]` entries carry `type`, `path`, `id`, and usually `uid`.
  `[sub_resource]` entries carry `type` and `id`. Nodes reference them as
  `ExtResource("id")` / `SubResource("id")`.
- `unique_name_in_owner = true` on a node enables `%Name` lookups from scripts
  in the same scene.
- Script properties set in the scene (`trigger = ExtResource("…")`) must match
  `@export` names exactly; renaming an export orphans the scene value
  silently.

## uid rules

- **Never invent `uid://` values.** Omit the attribute on files you author —
  Godot assigns one on the next import. Preserve existing uids when editing.
- Run the import before committing so every new `.gd` gets its `.uid`
  sidecar, and commit those sidecars with the change:

```powershell
Start-Process godot -ArgumentList "--headless", "--import", "--path", "src" -Wait
git status --porcelain | Select-String '\.uid'   # nothing unstaged
```

- `.tscn`/`.tres` uids live in the file header; `.uid` sidecar files belong to
  scripts and are Godot-generated — never hand-edit either.

## Scene-first rules

- **If a node lives as long as its parent, it is declared in the `.tscn`.**
  `_ready()` does not assemble static structure. Collision shapes are authored
  in-scene, not constructed in code.
- **Tunables live in the scene or a resource, not in GDScript literals.** The
  test: could a designer change this in the editor without touching code?
- **No `load("res://…")` string paths in gameplay code** — renames fail at
  runtime, not at parse time. The screen-manager seam is the sanctioned
  exception (ARCHITECTURE.md names it).

## GUIDE wiring

A new input = three files, all `.tres`: the action
(`src/guide/<mode>/actions/`), a mapping for it in that mode's context
(`src/guide/<mode>/<mode>_kbm_context.tres` / `_controller_context.tres`),
and the consumer referencing the action via `@export var x: GUIDEAction`.
Contexts are enabled per game mode by GuideService — a new game mode needs an
InputModeContext entry in `src/app/root/root.tscn`'s input context resource.

## Scene errors surface only at runtime

`check_scripts.ps1` proves scripts compile; it does not prove a scene loads.
After a structural `.tscn` change, boot it: the run-game skill headless check,
or the scenario suite if a harness covers it.
