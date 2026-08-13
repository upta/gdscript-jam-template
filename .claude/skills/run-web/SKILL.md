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

## The mono trap

Godot 4's **mono editor cannot export web** — it refuses outright, even for a
pure-GDScript project, and the mono template bundle ships no web templates.
`export_web.ps1` handles this itself: if the resolved godot is mono (or the
wrong version), it downloads the standard 4.7.1 editor to a local cache
(~55 MB) and installs the standard template bundle (~1 GB, one time), then
exports with that. CI's godot-ci container is a standard build with its own
templates — the deploy pipeline runs these same export-and-prove steps on
tag push.
