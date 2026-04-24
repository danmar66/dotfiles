# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Personal dotfiles repo organized around the XDG Base Directory spec. Configs live under `.config/<tool>/` at the repo root; `scripts/install-xdg.sh` creates symlinks from `$HOME` / `$XDG_CONFIG_HOME` into here so edits propagate to git automatically. There is no build or test system — work is almost entirely shell scripts and rc files.

## Common commands

```bash
bash scripts/install-xdg.sh    # create/refresh all symlinks (idempotent, backs up existing files)
bash scripts/verify.sh         # health check — exit 0 if healthy, 1 if anything wrong
shellcheck scripts/**/*.sh     # lint (not wired in; run manually before committing script changes)
```

There is no test suite. To validate a config edit, re-run `bash scripts/install-xdg.sh` and restart the relevant tool (IDE / shell).

## Architecture

`scripts/install-xdg.sh` is the single entry point for creating symlinks. All shared bash helpers live in `scripts/lib/common.sh` — `link_file`, `backup_file`, `log_*`, color vars, `DOTFILES_DIR`. Other scripts source it via the `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" && source "$SCRIPT_DIR/lib/common.sh"` pattern. Adding a new config = drop it under `.config/<tool>/`, add a `link_file` call in `install-xdg.sh`, update `README.md`.

`scripts/migrate-xdg.sh` is a one-shot migration from the pre-XDG layout — not needed for fresh clones. It performs `git mv` of old paths into `.config/`, backs the old state to `~/.cache/dotfiles-backups/`, and calls `install-xdg.sh` at the end. Leaves changes staged for a manual commit.

`scripts/verify.sh` is a read-only health check. Exit 0 if all symlinks + env vars + syntax checks pass, 1 otherwise. Uses `set -uo pipefail` (not `-e`) so it collects all failures rather than aborting on the first.

## XDG layout

- `~/.zshenv` (symlinked to `/.zshenv` in repo) is the only zsh config that stays in `$HOME`. It sets `ZDOTDIR=$XDG_CONFIG_HOME/zsh` so zsh finds `.zshrc` and `.zprofile` under XDG. `.zprofile` runs too late to relocate configs — that's why `.zshenv` exists.
- `~/.bashrc` is a thin wrapper that sources `$XDG_CONFIG_HOME/bash/bashrc`. Bash does not read `$XDG_CONFIG_HOME` natively, so a bootstrap in `$HOME` is required.
- IdeaVim reads only `~/.ideavimrc` (JetBrains hard-codes the path); the repo file at `.config/ideavim/ideavimrc` is symlinked there directly, not into `$XDG_CONFIG_HOME/ideavim/`.
- `.config/vim/` and `.config/nvim/` are empty placeholder directories. To populate either: drop the config file in, add a `link_file` call in `scripts/install-xdg.sh`. For vim, `.config/zsh/.zprofile` already picks up `$XDG_CONFIG_HOME/vim/vimrc` via a guarded `VIMINIT` export when the file appears. Neovim has native XDG support; no env var needed.
- `CLAUDE_CODE_TASKS.md` is the historical migration plan. Consult it for rationale on design decisions (ZDOTDIR placement, empty-dir handling, etc).

## IdeaVim config notes

`.config/ideavim/ideavimrc` uses `<Space>` as `<leader>`. Leader-key namespaces are organized by two-letter prefix (e.g., `s*` goto/search, `g*` goto-declaration family, `r*` refactor, `w*` windows, `a*` intention/actions, `c*` file-path/config). Preserve these namespaces when adding bindings so the which-key popup stays coherent. Window navigation uses `<A-hjkl>` and line movement uses `<C-k>` / `<C-l>` — these are deliberate user preferences, don't rewrite them to standard Vim defaults.
