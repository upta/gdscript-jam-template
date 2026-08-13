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
   `AppName` in `validation.config.psd1`. (The playtest workflow needs no
   rename — its Pages project name derives from the repo name.)
4. **itch.io:** create the project (Kind: HTML, viewport 1280×720, no
   payments). Create an API key (itch.io → Settings → API keys) and save it
   as the `ITCHIO_API_KEY` repository secret (Settings → Secrets and
   variables → Actions).
5. **Playtest secrets:** in the same Secrets and variables screen, add the
   `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` secrets and the
   `R2_PUBLIC_BASE` variable — same values as your other repos; where they
   come from the first time is § Branch playtests below. (Secrets and
   variables never copy through "Use this template".)
6. **First deploy:** `git tag v0.0.1 && git push origin v0.0.1` — or
   Actions → Deploy → Run workflow. After the first upload, tick
   **"This file will be played in the browser"** on the itch upload and save.
7. **Fill SPEC.md** (or run `/spec` in Claude Code) before the first feature.

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

Every push to a non-main branch uploads the web build to Cloudflare R2 at
`https://<bucket-public-url>/<repo>/<branch>/index.html` (D9) — throwaway
URLs testers just click, while itch.io stays prod. (R2, not Cloudflare
Pages: Pages caps files at 25 MiB and a stock Godot 4 web wasm is ~38 MiB.)

**Once per Cloudflare account** (the free tier is plenty —
<https://dash.cloudflare.com>):

1. **Create the shared bucket** — one bucket serves every game; uploads are
   keyed `<repo>/<branch>/`, so repos can't collide:

   ```powershell
   npx wrangler login
   npx wrangler r2 bucket create playtests
   npx wrangler r2 bucket dev-url enable playtests
   ```

   (Dashboard alternative: R2 → Create bucket → `playtests`, then the
   bucket's Settings → Public access → allow the r2.dev subdomain.)
   Copy the public base URL it gives you — `https://pub-<hash>.r2.dev`.
2. **Get the `CLOUDFLARE_API_TOKEN` value** — dashboard → My Profile → API
   Tokens → Create Token → Custom token, with exactly one permission:
   **Account → Workers R2 Storage → Edit**, scoped to your account. Copy it
   immediately — it is shown once. (If you have an older token, editing its
   permission works too.)
3. **Get the `CLOUDFLARE_ACCOUNT_ID` value** — dashboard → Workers & Pages
   or R2; the Account ID is in the right-hand sidebar. (It's also the hex
   segment in the dashboard URL.)

**Per repo** (secrets and variables do **not** copy through "Use this
template" — same as `ITCHIO_API_KEY`):

4. **Add both secrets** — repo → Settings → Secrets and variables →
   Actions → New repository secret: `CLOUDFLARE_API_TOKEN` and
   `CLOUDFLARE_ACCOUNT_ID` (the same values work on the same account).
5. **Optional but nice:** add a repository **variable** named
   `R2_PUBLIC_BASE` with the `https://pub-<hash>.r2.dev` base from step 1 —
   the workflow's run summary then prints a clickable playtest link.

The r2.dev URL is rate-limited by Cloudflare — fine for playtests; attach a
custom domain to the bucket if it ever matters.

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
