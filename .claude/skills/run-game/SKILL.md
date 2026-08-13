---
name: run-game
description: Use to launch the real game and verify it boots and runs clean — headless with a positive marker for verification, windowed for humans.
---

# Run the game

## Headless boot check (verification)

```powershell
$log = Join-Path $env:TEMP "jam_boot_verify.log"
$p = Start-Process godot -ArgumentList "--headless", "--path", "src", "--quit-after", "600", "--log-file", $log -Wait -PassThru -WindowStyle Hidden
$p.ExitCode                                                  # must be 0
Select-String -Path $log -Pattern '\[App\] Screen ready:'    # MUST appear
Select-String -Path $log -Pattern 'SCRIPT ERROR|ERROR'       # must produce nothing
```

- **Assert the positive marker, don't just count errors:** a boot that dies
  before the first screen logs no errors at all, and an absence-of-errors
  check calls that a pass. The marker is
  `[App] Screen ready: res://main_menu/main_menu.tscn`.
- **`--quit-after` + `Start-Process -Wait`, never Stop-Process** — force-kill
  loses buffered output, the log comes back 0 bytes, the grep finds nothing,
  and it reads as clean. godot.exe is GUI-subsystem: a bare invocation
  returns immediately, so `-Wait` is load-bearing.
- Runtime logs are held fully strict: the known editor-pass UID noise
  (CLAUDE.md § Known issues) never appears at runtime, so any ERROR here is
  real.

## Windowed (humans)

```powershell
./test-run.ps1    # branch picker → pull → blocking import → run
```

or `godot --path src` for just the game. In the demo: hover a character for
the prompt, LMB attacks, RMB heals.

## After pulling assets or switching branches

Re-import before trusting a run — a real-game boot doesn't auto-import, so a
stale `.godot` cache renders pulled sprites blank. `test-run.ps1` does this
every run; done manually it's:

```powershell
Start-Process godot -ArgumentList "--headless", "--import", "--path", "src" -Wait
```
