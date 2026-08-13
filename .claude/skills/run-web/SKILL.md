---
name: run-web
description: Use to prove the WEB build works — export the Web preset, verify it actually produced files, serve it locally, and check the boot marker in the browser console.
---

# Run the web build

Ship-shaped verification. The desktop engine passing proves nothing about the
exported build: the preset excludes the validation addon, the pck has its own
resource resolution, and web runs GL Compatibility on WebGL2.

1. **Export and prove:**

```powershell
powershell src/tools/export_web.ps1
```

The script checks `index.html` / `index.pck` / `index.wasm` exist and are
non-empty, because `--export-release` exits 0 even when an unknown preset
writes nothing — the files are the check, never the exit code.

2. **Serve:**

```powershell
powershell src/tools/serve_web.ps1    # http://localhost:8060
```

Correct wasm mime, no caching. `-CrossOriginIsolation` only matters if the
preset ever enables thread support (the default single-threaded build matches
itch.io's no-special-headers hosting).

3. **Boot check in a real browser** at `http://localhost:8060`: the console
   must show `[App] Screen ready: res://main_menu/main_menu.tscn` and no
   errors, and the menu must actually render — look at it.

## Export templates (one-time, local)

Desktop exports need the 4.7.1 template bundle. If `export_web.ps1` reports
them missing: download `Godot_v4.7.1-stable_export_templates.tpz` from the
Godot 4.7.1 release page and extract its `templates/` contents into
`%APPDATA%\Godot\export_templates\4.7.1.stable\`. CI's godot-ci container
ships them already — the deploy pipeline runs these same export-and-prove
steps on tag push.
