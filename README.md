# gdscript-jam-template

Godot 4.7 GDScript game-jam template: web export to itch.io with tag-driven
deploys, and an agent-ready workflow — in-engine validation scenarios,
Claude Code skills/commands/hooks, G.U.I.D.E input, Provider DI.

The demo (two characters, attack/heal through the interaction system) is
living documentation: ARCHITECTURE.md's golden path walks it end to end.
Play it, pattern-match it, replace it.

## Jam day one

1. **Use this template** on GitHub, then clone WITH the submodule:
   `git clone --recurse-submodules <your-repo>` (or `git submodule update
   --init` after a plain clone).
2. **`./setup.ps1`** (Windows) or `./setup.sh` — materializes the validation
   kit symlinks and runs the first asset import.
3. **Rename things:** `config/name` in `src/project.godot`;
   `ITCHIO_USERNAME` / `ITCHIO_GAME` in `.github/workflows/deploy.yml`;
   `AppName` in `validation.config.psd1`.
4. **itch.io:** create the project (Kind: HTML, viewport 1280×720, no
   payments). Create an API key (itch.io → Settings → API keys) and save it
   as the `ITCHIO_API_KEY` repository secret (Settings → Secrets and
   variables → Actions).
5. **First deploy:** `git tag v0.0.1 && git push origin v0.0.1` — or
   Actions → Deploy → Run workflow. After the first upload, tick
   **"This file will be played in the browser"** on the itch upload and save.
6. **Fill SPEC.md** (or run `/spec` in Claude Code) before the first feature.

## The loop

`/spec → /plan → /build …repeat… → /ship → /merge`. CLAUDE.md is the
contract, ARCHITECTURE.md the map, DECISIONS.md the contested calls.

- The verification gate: `./validate.ps1` (the scenario suite;
  `-RepeatCount 3` for flakiness checks)
- The human dev loop: `./test-run.ps1` (branch picker → pull → import → run)

## Deploys are deliberate

Pushing `main` builds nothing (D7). A `v*` tag — or a manual workflow run —
exports the Web preset, proves the build actually produced files, and pushes
it to itch.io with the tag as the version. CI (script compile + format/lint)
runs on every PR and push to main.

## Without Claude

Everything verifies from a plain shell:

| Command | What it proves |
| --- | --- |
| `./validate.ps1` | The scenario suite, with screenshots as evidence |
| `src/tools/check_scripts.ps1` | Every script compiles |
| `src/tools/lint.ps1` | gdformat + gdlint clean (`-Fix` applies formatting) |
| `src/tools/export_web.ps1` → `serve_web.ps1` | The web build exists and serves at localhost:8060 |
| `./test-run.ps1` | The game runs, on fresh assets |

## Updating the validation kit

```powershell
git -C submodules/agentic_godot_validation pull origin main
git add submodules/agentic_godot_validation
git commit -m "chore(kit): bump agentic-godot-validation"
./setup.ps1
```

## Requirements

- **Godot 4.7.1** on PATH (or set `GODOT_EXE`). Export templates are only
  needed for local web exports — CI's container ships them; locally,
  `export_web.ps1` tells you how to install them if they're missing.
- **PowerShell 7** (`pwsh`) for the validation suite runner.
- **Python + gdtoolkit** (`pip install "gdtoolkit==4.*"`, 4.5.0+) for
  format/lint — optional locally, enforced in CI.
