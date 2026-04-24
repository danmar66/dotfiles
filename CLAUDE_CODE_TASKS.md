# CLAUDE CODE TASKS — XDG migration (v2)

Roadmap for migrating this dotfiles repo to an XDG Base Directory layout, modeled on voidrice (Luke Smith). Each task is a copy-paste prompt for Claude Code. Run them **in order**; later tasks depend on files from earlier tasks.

---

## Design decisions (read before running any task)

- **ZDOTDIR is set in `~/.zshenv`, not `.zprofile`.** `.zprofile` runs after zsh has already looked for `.zshrc` in `$HOME`, so moving `.zshrc` via `.zprofile` is too late. `.zshenv` is the only zsh startup file that must stay in `$HOME`.
- **Repo mirror layout.** Configs live under `.config/<tool>/` at the repo root (voidrice-style), symlinked into `~/.config/<tool>/`. This matches $HOME 1:1 and keeps paths predictable. Trade-off: GitHub hides dotfile-prefixed directories in the listing — acceptable because this is a personal repo.
- **Real files only.** The only configs currently tracked are `.ideavimrc`, `.zshrc`, `.bashrc`. Tasks touch only those. `.gitconfig`, `.tmux.conf`, `.editorconfig`, `.prettierrc` are NOT migrated — add them later with a one-line `link_file` call once the files actually exist.
- **Separate editor directories.** `ideavim/`, `vim/`, `nvim/` are distinct trees under `.config/` — they share nothing at the config level (IdeaVim is a Vim subset with JetBrains extensions; vim ≠ neovim syntax). Only `.config/ideavim/ideavimrc` is populated today; `.config/vim/` and `.config/nvim/` are created empty (with `.gitkeep`) so future configs have a home.
  - IdeaVim: symlinked to `~/.ideavimrc` (JetBrains reads only $HOME, no XDG support).
  - Vim: loaded via `VIMINIT` pointing at `$XDG_CONFIG_HOME/vim/vimrc` (set in `.zprofile` only when the file exists — guard with `[ -f ... ]`).
  - Neovim: native XDG — reads `$XDG_CONFIG_HOME/nvim/init.{vim,lua}` automatically, no env var needed.
- **bash needs a wrapper.** Bash does not read from `$XDG_CONFIG_HOME`. A thin `~/.bashrc` in `$HOME` sources the XDG copy.
- **One installer.** `install-xdg.sh` owns all symlink logic. `migrate-xdg.sh` only moves files, then calls `install-xdg.sh`. Shared helpers live in `scripts/lib/common.sh`.
- **Old `install.sh` is deleted** as part of the migration. Two installers = two sources of truth.

### Known non-blockers (documented gaps)

- **Oh My Zsh state stays outside XDG.** `.zshrc` sources `$HOME/.oh-my-zsh`; OMZ writes logs to `$ZSH/log/` inside that tree. Moving OMZ to `$XDG_DATA_HOME/oh-my-zsh` is possible but fights the OMZ installer on every update. Accepted as-is.
- **macOS portability is partial.** `readlink -f` is a GNU extension and fails on macOS without `coreutils`. `scripts/lib/common.sh` uses `cd && pwd` for path resolution (portable) and `scripts/verify.sh` prefers `realpath` with a Python fallback. All other scripts use portable constructs. Tested on Linux; macOS works but is not CI-verified.
- **Tools that auto-edit `~/.bashrc` (NVM, rvm) will write into the wrapper.** The wrapper is thin, so appended blocks still function — but they're outside git tracking. If this happens, manually move the block into `$XDG_CONFIG_HOME/bash/bashrc`.
- **Empty `.config/vim/` and `.config/nvim/` directories** exist as placeholders. Populating either requires adding a `link_file` call in `install-xdg.sh` AND (for vim) ensuring `VIMINIT` guard in `.zprofile` picks up the new file on next login.

Final layout after all tasks:

```
dotfiles/
├── README.md                        # UPDATED (2 new sections)
├── .zshenv                          # NEW — sets ZDOTDIR, symlinked to ~/.zshenv
├── .bashrc                          # NEW — thin wrapper, symlinked to ~/.bashrc
├── .config/
│   ├── zsh/
│   │   ├── .zshrc                   # moved from shell/.zshrc
│   │   └── .zprofile                # NEW — login-time init
│   ├── bash/
│   │   └── bashrc                   # moved from shell/.bashrc
│   ├── ideavim/
│   │   └── ideavimrc                # moved from ideavim/.ideavimrc
│   ├── vim/
│   │   └── .gitkeep                 # empty — populate later
│   └── nvim/
│       └── .gitkeep                 # empty — populate later
└── scripts/
    ├── lib/
    │   └── common.sh                # shared bash helpers
    ├── install-xdg.sh               # creates symlinks
    ├── migrate-xdg.sh               # one-shot: move files + delete install.sh + install
    └── verify.sh                    # exit 0 if healthy, 1 otherwise

Removed: install.sh, ideavim/, shell/, terminal/, ide/, other/
```

---

## TASK 0: Generate scripts/lib/common.sh

**Prompt:**

```
Create scripts/lib/common.sh — a bash library sourced by every other script in this repo. It must be source-able (no `set -e` at the top level, no `exit`), and safe to source multiple times.

No shebang (this file is sourced, never executed).

Must work correctly when the caller has `set -euo pipefail` active — guard every variable expansion with defaults (`${VAR:-}`), never reference a potentially-unset var bare.

Exports (as functions):
- color vars: RED, GREEN, YELLOW, BLUE, NC — guard definition with `[[ -z "${RED:-}" ]]` so double-sourcing is safe; after guard, mark readonly.
- log_info(msg), log_ok(msg), log_warn(msg), log_err(msg) — prefixed colored output (log_err to stderr).
- link_file(src, dst) — idempotent symlink creation. Behavior:
    * if dst is already the correct symlink: log_ok, return 0
    * if dst is a wrong symlink: rm and recreate
    * if dst is a regular file: back up to dst.backup.$(date +%s), then symlink
    * create parent dir of dst if missing
    * error and return 1 if src does not exist
- backup_file(path) — move to path.backup.$(date +%s), return new path on stdout
- require_cmd(cmd) — exit 1 with clear message if cmd not on PATH
- DOTFILES_DIR — resolved absolute path of the repo root (parent of scripts/). Use `cd ... && pwd` rather than `readlink -f` so it works on macOS too.

Style:
- Reuse the existing link_file helper from install.sh as a starting point — it already handles backup + idempotency correctly.
- Pass shellcheck with zero warnings at default severity.
- No top-level side effects other than setting readonly vars.

After generation: `chmod 644 scripts/lib/common.sh` (sourced file, does not need exec bit).
```

---

## TASK 1: Generate .zshenv

**Prompt:**

```
Create .zshenv at the repo root. This file will be symlinked to ~/.zshenv and is the ONLY zsh config that stays in $HOME. Its sole job is to set ZDOTDIR so zsh finds the rest of its config under XDG.

Contents:
- Export XDG_CONFIG_HOME, XDG_DATA_HOME, XDG_CACHE_HOME, XDG_STATE_HOME with defensive defaults (${VAR:=default} pattern) in case a login manager didn't set them.
- Export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
- Export HISTFILE="$XDG_STATE_HOME/zsh/history" and ensure the dir exists (mkdir -p).
- Nothing else. No PATH manipulation, no aliases, no sourcing.

Keep it under 20 lines. Comment each block in one short line.
```

---

## TASK 2: Generate .config/zsh/.zprofile

**Prompt:**

```
Create .config/zsh/.zprofile. This runs at login (after .zshenv), before .zshrc.

No shebang (zsh startup file).

Responsibilities:
- Prepend $HOME/.local/bin to PATH only if not already present. Use this exact pattern:
    ```
    case ":${PATH}:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
    ```
- Set GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config" (even though git/config isn't tracked yet — setting it is harmless and future-proofs).
- Set VIMINIT only if $XDG_CONFIG_HOME/vim/vimrc exists: `[ -f "$XDG_CONFIG_HOME/vim/vimrc" ] && export VIMINIT="source $XDG_CONFIG_HOME/vim/vimrc"`. Guarded so an empty vim/ dir does not break vim.
- Do NOT set ZDOTDIR (.zshenv did that).
- Do NOT source .zshrc (zsh does that automatically for interactive shells).
- Do NOT set anything for neovim (native XDG support).
- Do NOT set anything for ideavim (JetBrains hard-codes ~/.ideavimrc).

Keep it minimal. No GNUPGHOME, PASSWORD_STORE_DIR, SQLITE_TMPDIR — those are not used in this repo.
```

---

## TASK 3: Generate .bashrc wrapper

**Prompt:**

```
Create .bashrc at the repo root — this will be symlinked to ~/.bashrc. It is a thin bootstrap that sources the real config from XDG (since bash does not read $XDG_CONFIG_HOME natively).

No shebang (bash startup file).

Contents:
- Set XDG_CONFIG_HOME default if unset (`: "${XDG_CONFIG_HOME:=$HOME/.config}"`).
- If $XDG_CONFIG_HOME/bash/bashrc exists and is readable, source it.
- No other logic.

Keep under 10 lines.

Known tradeoff to comment inline: installers that append to `~/.bashrc` directly (NVM, rvm, some CLI tools) will write into this wrapper file, bypassing the XDG copy. If that happens, move the appended block into `$XDG_CONFIG_HOME/bash/bashrc` manually.
```

---

## TASK 4: Generate scripts/install-xdg.sh

**Prompt:**

```
Create scripts/install-xdg.sh — the single installer that creates all symlinks for the XDG layout.

Structure:
- `#!/usr/bin/env bash`
- `set -euo pipefail`
- At top, after sourcing common.sh, provide XDG defaults in case caller hasn't set them:
    ```
    : "${XDG_CONFIG_HOME:=$HOME/.config}"
    : "${XDG_DATA_HOME:=$HOME/.local/share}"
    : "${XDG_STATE_HOME:=$HOME/.local/state}"
    export XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME
    ```
- Source scripts/lib/common.sh by resolving path relative to the script itself, not CWD:
    ```
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # shellcheck source=lib/common.sh
    source "$SCRIPT_DIR/lib/common.sh"
    ```

Preflight:
- If `$DOTFILES_DIR/.config` does not exist, log_err with message "install-xdg.sh requires the XDG layout. Run scripts/migrate-xdg.sh first." and exit 1. This prevents running the installer on a pre-migration tree.

Create XDG base dirs if missing: $XDG_CONFIG_HOME, ~/.local/bin, $XDG_DATA_HOME, $XDG_STATE_HOME/zsh.

Create symlinks (using link_file from common.sh):
- $DOTFILES_DIR/.zshenv                   → ~/.zshenv
- $DOTFILES_DIR/.bashrc                   → ~/.bashrc
- $DOTFILES_DIR/.config/zsh/.zshrc        → $XDG_CONFIG_HOME/zsh/.zshrc
- $DOTFILES_DIR/.config/zsh/.zprofile     → $XDG_CONFIG_HOME/zsh/.zprofile
- $DOTFILES_DIR/.config/bash/bashrc       → $XDG_CONFIG_HOME/bash/bashrc
- $DOTFILES_DIR/.config/ideavim/ideavimrc → ~/.ideavimrc  (IdeaVim reads from $HOME, not XDG)

No links for vim/ or nvim/ — they are empty placeholders. When the first file is added to either dir, add a matching link_file call to this installer. Dir-level symlinks are avoided so vim/nvim runtime state (undodir, swap, viminfo) does not leak into the repo.

End with a one-line summary: how many links created / updated / skipped.

Shellcheck must pass at default severity.

After generation: `chmod +x scripts/install-xdg.sh` and commit with exec bit preserved (`git update-index --chmod=+x scripts/install-xdg.sh` if already tracked).
```

---

## TASK 5: Generate scripts/migrate-xdg.sh

**Prompt:**

```
Create scripts/migrate-xdg.sh — a one-shot migration from the current ideavim/ + shell/ layout to the XDG layout. This script is destructive (it moves files in the repo) so it backs up first.

Structure:
- `#!/usr/bin/env bash`
- `set -euo pipefail`
- Source common.sh the same way install-xdg.sh does (SCRIPT_DIR pattern).

Behavior:
1. Accept --dry-run. In dry-run, print every `mv`/`rm`/`mkdir`/`ln`/`git mv`/`git rm` that would run via `log_info`, do nothing else. Dry-run MUST skip the tar snapshot too.

2. Preflight (abort with log_err + exit 1 on failure):
   - `git rev-parse --show-toplevel` returns a path. Confirm we're at its root by comparing to $DOTFILES_DIR.
   - `git status --porcelain` is empty (no uncommitted or untracked changes except this script itself). Refuse on dirty tree to avoid mixing migration with unrelated WIP.
   - `cd "$DOTFILES_DIR"` so all subsequent paths are repo-relative.
   - Exit with a clear "already migrated" message if `.config/` already exists at the repo root.
   - Verify at least one of the expected source files exists (`ideavim/.ideavimrc`, `shell/.zshrc`, `shell/.bashrc`). If none exist, there's nothing to migrate.

3. Create a tar snapshot of the pre-migration state at `$HOME/.cache/dotfiles-backups/pre-xdg.$(date +%s).tar.gz` (mkdir -p first). Include only files that exist: ideavim/, shell/, install.sh. Store OUTSIDE the repo so it doesn't pollute `git status`.

4. Use `git mv` (preserves history) to move. `mkdir -p` the parent first, then `git mv`:
   - .config/ideavim/ ← ideavim/.ideavimrc → ideavimrc (rename drops leading dot)
   - .config/zsh/     ← shell/.zshrc       → .zshrc
   - .config/bash/    ← shell/.bashrc      → bashrc   (drops leading dot)
   Also `mkdir -p .config/vim .config/nvim` and `touch .config/vim/.gitkeep .config/nvim/.gitkeep`, then `git add` them.
   If any source file doesn't exist, log_warn and continue — don't abort.

5. Delete the old install.sh (with `git rm`) if it exists. The new installer replaces it.

6. Remove now-empty ideavim/, shell/, terminal/, ide/, other/ directories (only if empty — use `rmdir`, which fails on non-empty, catch with `||` and log_warn).

7. Call scripts/install-xdg.sh to create the symlinks.

8. Commit workflow: the script leaves all `git mv` / `git rm` / `git add` changes STAGED but does NOT commit. User commits manually. Print at the end:

    ```
    Migration staged. Review with:
        git status
        git diff --staged
    Then commit:
        git commit -m "migrate to XDG layout"
    Next:
        exec $SHELL           # pick up ZDOTDIR
        bash scripts/verify.sh
    Rollback if needed:
        git reset --hard HEAD
        tar xzf ~/.cache/dotfiles-backups/pre-xdg.<timestamp>.tar.gz
    ```

Notes:
- No per-file confirmations. This is run once.
- Shellcheck must pass at default severity.

After generation: `chmod +x scripts/migrate-xdg.sh`.
```

---

## TASK 6: Generate scripts/verify.sh

**Prompt:**

```
Create scripts/verify.sh — a read-only health check. Exit 0 if everything is fine, exit 1 if any check fails. No flags, no auto-fix.

Structure:
- `#!/usr/bin/env bash`
- `set -uo pipefail` (NOT `-e` — we want to collect all failures, not abort on first).
- Source scripts/lib/common.sh (SCRIPT_DIR pattern, same as install-xdg.sh).

Track failures with a counter; each failed check increments it; exit with 0 if counter is 0, else 1.

Checks (print ✓ / ✗ per check, with a single-line reason on failure):
1. ZDOTDIR is exported and equals "$XDG_CONFIG_HOME/zsh".
2. HISTFILE is exported and points under $XDG_STATE_HOME.
3. Each expected symlink exists, is a symlink, and its readlink target starts with $DOTFILES_DIR:
   - ~/.zshenv
   - ~/.bashrc
   - ~/.ideavimrc
   - $XDG_CONFIG_HOME/zsh/.zshrc
   - $XDG_CONFIG_HOME/zsh/.zprofile
   - $XDG_CONFIG_HOME/bash/bashrc
4. No broken symlinks among the above (dereference passes `-e`).
5. Each target file is non-empty (`[[ -s $path ]]`). Empty config is almost always a bug.
6. `zsh -n $XDG_CONFIG_HOME/zsh/.zshrc` parses cleanly.
7. `zsh -n $XDG_CONFIG_HOME/zsh/.zprofile` parses cleanly.
8. `bash -n $XDG_CONFIG_HOME/bash/bashrc` parses cleanly.
9. `$XDG_CONFIG_HOME/ideavim/ideavimrc` and `~/.ideavimrc` resolve to the same real path (`readlink -f` not portable to macOS — use `realpath` if present, otherwise `python3 -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' "$path"`).
10. `$XDG_CONFIG_HOME/vim/` and `$XDG_CONFIG_HOME/nvim/` directories exist (even if empty) — warn only, don't fail, if they don't.

Ends with "PASS" or "FAIL: N check(s) failed". Shellcheck must pass at default severity.

After generation: `chmod +x scripts/verify.sh`.
```

---

## TASK 7: Update README.md

**Prompt:**

```
Update README.md. Surgical edits only — do not rewrite the whole file.

1. In "Quick Setup → Clone & Install", replace `bash install.sh` with `bash scripts/install-xdg.sh`.

2. Replace the "Directory Structure" code block with the new XDG tree (see Design decisions section of CLAUDE_CODE_TASKS.md for the exact layout).

3. Add a new top-level section "## Migration from pre-XDG layout" directly after Quick Setup, containing:
   - One sentence explaining the layout changed to XDG.
   - Four commands, in order: `git pull`, `bash scripts/migrate-xdg.sh`, `exec $SHELL`, `bash scripts/verify.sh`.
   - One sentence on rollback: "Pre-migration state is in `~/.cache/dotfiles-backups/pre-xdg.<timestamp>.tar.gz`; restore with `git reset --hard HEAD && tar xzf <that file>`."

Remove:
- Any reference to old paths: `ideavim/.ideavimrc`, `shell/.bashrc`, `git/.gitconfig`, `vim/.ideavimrc`.
- The "Manual Setup (if preferred)" section — with symlinks it's obsolete.
- References to DOTFILES_SETUP.md / QUICK_DOTFILES_SETUP.md / KEYBOARD_TERMINAL_GUIDE.md / MERGE_REPORT.md (they don't exist).
- Any other remaining `install.sh` mentions (Troubleshooting section, etc.).

Keep: Features, IdeaVim Configuration, Troubleshooting, License, Credits, Contact.

Do not create STRUCTURE.md or MIGRATION.md.
```

---

## TASK 8: Update CLAUDE.md

**Prompt:**

```
Update CLAUDE.md to reflect the new layout.

1. "Architecture" section: replace the description of install.sh with a description of scripts/install-xdg.sh + scripts/lib/common.sh. Note that helpers now live in common.sh and must be sourced from there.
2. Delete the entire "Known drift between docs and reality" section — the drift is fixed after this migration.
3. "Planned XDG migration" section: replace with a one-paragraph "XDG layout" section pointing at CLAUDE_CODE_TASKS.md as historical reference.
4. "Common commands": replace `bash install.sh` with `bash scripts/install-xdg.sh`. Keep shellcheck guidance.
5. "IdeaVim config notes" stays unchanged, but update the path: `ideavim/.ideavimrc` → `.config/ideavim/ideavimrc`.
6. Add a one-paragraph note that `.config/vim/` and `.config/nvim/` are reserved placeholder directories — populating either requires adding a `link_file` call in `scripts/install-xdg.sh` (and VIMINIT already picks up `$XDG_CONFIG_HOME/vim/vimrc` automatically when the file appears).
```

---

## TASK 9: Lint and smoke-test

**Prompt:**

```
Run in order, stop on first failure:

1. `shellcheck` at default severity on every shell script: `scripts/lib/common.sh`, `scripts/install-xdg.sh`, `scripts/migrate-xdg.sh`, `scripts/verify.sh`, `.bashrc`, `.zshenv`, `.config/zsh/.zprofile`, `.config/bash/bashrc`.
2. `bash -n` on every `.sh` file.
3. `zsh -n` on `.config/zsh/.zshrc` and `.config/zsh/.zprofile` and `.zshenv`.
4. `bash scripts/install-xdg.sh` — must be idempotent. Run twice; second run reports all "already linked".
5. `bash scripts/verify.sh` — must exit 0.
6. Spawn a fresh zsh (WITHOUT `exec`, so the current session isn't replaced) and print env:
    ```
    zsh -l -c 'echo "ZDOTDIR=$ZDOTDIR HISTFILE=$HISTFILE PATH=$PATH" && echo ok'
    ```
   Expect: ZDOTDIR = `$XDG_CONFIG_HOME/zsh`, HISTFILE under `$XDG_STATE_HOME/zsh/`, `$HOME/.local/bin` present in PATH exactly once.

Report any failures with file + line. If all pass, say so explicitly.
```

---

## Execution order

```
Task 0 → scripts/lib/common.sh
Task 1 → .zshenv
Task 2 → .config/zsh/.zprofile
Task 3 → .bashrc
Task 4 → scripts/install-xdg.sh
Task 5 → scripts/migrate-xdg.sh
Task 6 → scripts/verify.sh
# at this point the new files exist but the old layout is untouched
# running Task 5 (migrate-xdg.sh) performs the actual cutover
Task 7 → README.md
Task 8 → CLAUDE.md
Task 9 → lint + smoke test
```

Commit at natural boundaries: one commit for Tasks 0–6 (new files, old layout still works), one commit for the migrate-xdg.sh execution output (the git mv diff), one commit for Tasks 7–8 (docs), final commit squashes if desired.
