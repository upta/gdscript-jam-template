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
   `PAGES_PROJECT` in `.github/workflows/playtest.yml`; `AppName` in
   `validation.config.psd1`.
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

## Branch playtests

Every push to a non-main branch deploys the web build to Cloudflare Pages at
`https://<branch>.<project>.pages.dev` (D8) — throwaway URLs testers just
click, while itch.io stays prod. Setup, once per game:

1. **Cloudflare account** (the free tier is plenty):
   <https://dash.cloudflare.com>
2. **Create the Pages project** — its name must match `PAGES_PROJECT` in
   `.github/workflows/playtest.yml`:

   ```powershell
   npx wrangler login
   npx wrangler pages project create <name> --production-branch=main
   ```

   (Dashboard alternative: Workers & Pages → Create → Pages → Upload
   assets — it insists on a first upload; any file will do.)
3. **Get the `CLOUDFLARE_ACCOUNT_ID` value** — dashboard → Workers & Pages;
   the Account ID is in the right-hand sidebar. (It's also the hex segment
   in the dashboard URL.)
4. **Get the `CLOUDFLARE_API_TOKEN` value** — dashboard → My Profile → API
   Tokens → Create Token → Custom token, with exactly one permission:
   **Account → Cloudflare Pages → Edit**, scoped to your account. Copy it
   immediately — it is shown once.
5. **Add both as repository secrets** — repo → Settings → Secrets and
   variables → Actions → New repository secret, named exactly
   `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`.

GitHub does **not** copy secrets through "Use this template": every jam repo
needs both secrets added again (the same values work if it's the same
Cloudflare account) and its own Pages project — the same way each repo needs
its own `ITCHIO_API_KEY`.

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

- **Godot 4.7.1** on PATH (or set `GODOT_EXE`). Local web exports are
  self-sufficient: `export_web.ps1` downloads what it needs on first run —
  including a standard editor if yours is the mono build, which cannot
  export web in Godot 4.
- **PowerShell 7** (`pwsh`) for the validation suite runner.
- **Python + gdtoolkit** (`pip install "gdtoolkit==4.*"`, 4.5.0+) for
  format/lint — optional locally, enforced in CI.
