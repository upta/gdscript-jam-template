# /setup

One-time bootstrap for a repo freshly created from this template.

- Run `./setup.ps1` (materializes the validation kit symlinks, first asset
  import).
- Check what's already configured: `gh secret list` and `gh variable list`.
  Only act on what's missing — don't re-print commands for secrets already
  set.
- For each of `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`,
  `ITCHIO_API_KEY` that's missing, print the exact command to set it, each in
  its own fenced block — never two commands in one block, since each opens
  its own interactive paste prompt and bundling them risks the run-it-for-me
  button firing them as one non-interactive shot instead of three attached
  prompts. Never run these yourself and never accept the value in chat:

  ```bash
  gh secret set CLOUDFLARE_API_TOKEN
  ```

  ```bash
  gh secret set CLOUDFLARE_ACCOUNT_ID
  ```

  ```bash
  gh secret set ITCHIO_API_KEY
  ```

- If `R2_PUBLIC_BASE` is missing, print it pre-filled with the shared bucket's
  actual public URL — not secret, and the same bucket is reused across
  projects, so there's a real default rather than a placeholder. Still a
  command the human runs themselves, in case this repo ever points at a
  different bucket:

  ```bash
  gh variable set R2_PUBLIC_BASE --body "https://pub-7b5b2a5f9c7742c6b0f848ef5efb3efd.r2.dev"
  ```

- Remind, don't automate — no CLI covers these:
  - itch.io: create the project + API key (README § Jam day one, step 4),
    needed before `ITCHIO_API_KEY` means anything.
  - Renames: `config/name` in `src/project.godot`, `ITCHIO_USERNAME` /
    `ITCHIO_GAME` in `.github/workflows/deploy.yml`, `AppName` in
    `validation.config.psd1`.
- End with a short status: what's configured, what's still outstanding.
