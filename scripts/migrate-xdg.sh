#!/usr/bin/env bash
# scripts/migrate-xdg.sh — one-shot migration from ideavim/+shell/ layout to XDG.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=1
    log_info "DRY RUN — no changes will be made"
fi

run() {
    if (( DRY_RUN )); then
        log_info "would run: $*"
    else
        "$@"
    fi
}

# ---- Preflight ----

require_cmd git
require_cmd tar

git_root=$(git -C "$DOTFILES_DIR" rev-parse --show-toplevel 2>/dev/null || true)
if [[ -z "$git_root" ]]; then
    log_err "$DOTFILES_DIR is not inside a git repository"
    exit 1
fi
if [[ "$git_root" != "$DOTFILES_DIR" ]]; then
    log_err "script must run from repo root. git root is $git_root but DOTFILES_DIR is $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR"

# "already migrated" marker: post-migration files exist at their new XDG paths
if [[ -f ".config/ideavim/ideavimrc" ]] || [[ -f ".config/zsh/.zshrc" ]] || [[ -f ".config/bash/bashrc" ]]; then
    log_err "already migrated (found files under .config/). Nothing to do."
    exit 1
fi

# verify at least one source file exists
found_any=0
for src in ideavim/.ideavimrc shell/.zshrc shell/.bashrc; do
    [[ -f "$src" ]] && found_any=1
done
if (( ! found_any )); then
    log_err "no source files found under ideavim/ or shell/. Nothing to migrate."
    exit 1
fi

# dirty-tree: warn but continue (user explicitly invoked migration)
if ! git diff --quiet --cached; then
    log_warn "staged changes already present — migration will add to them"
fi

# ---- Snapshot ----

backup_dir="$HOME/.cache/dotfiles-backups"
ts=$(date +%s)
backup_path="$backup_dir/pre-xdg.${ts}.tar.gz"

run mkdir -p "$backup_dir"

snapshot_targets=()
for p in ideavim shell install.sh; do
    [[ -e "$p" ]] && snapshot_targets+=("$p")
done

if (( DRY_RUN )); then
    log_info "would tar czf $backup_path ${snapshot_targets[*]}"
else
    if (( ${#snapshot_targets[@]} > 0 )); then
        tar czf "$backup_path" "${snapshot_targets[@]}"
        log_ok "snapshot: $backup_path"
    fi
fi

# ---- git mv moves ----

move() {
    local src=$1
    local dst_dir=$2
    local dst_name=$3
    if [[ ! -f "$src" ]]; then
        log_warn "skip (missing): $src"
        return 0
    fi
    run mkdir -p "$dst_dir"
    run git mv "$src" "$dst_dir/$dst_name"
    log_ok "moved: $src → $dst_dir/$dst_name"
}

move ideavim/.ideavimrc .config/ideavim ideavimrc
move shell/.zshrc       .config/zsh     .zshrc
move shell/.bashrc      .config/bash    bashrc

# placeholder dirs for future vim/nvim configs
for d in .config/vim .config/nvim; do
    run mkdir -p "$d"
    if [[ ! -f "$d/.gitkeep" ]]; then
        if (( DRY_RUN )); then
            log_info "would touch $d/.gitkeep and git add it"
        else
            touch "$d/.gitkeep"
            git add "$d/.gitkeep"
        fi
    fi
done

# ---- drop old install.sh ----

if [[ -f install.sh ]]; then
    run git rm install.sh
    log_ok "removed old install.sh"
fi

# ---- tidy up empty dirs ----

for d in ideavim shell terminal ide other; do
    if [[ -d "$d" ]]; then
        if (( DRY_RUN )); then
            log_info "would rmdir $d if empty"
        else
            rmdir "$d" 2>/dev/null && log_ok "removed empty dir: $d" || log_warn "not empty, kept: $d"
        fi
    fi
done

# ---- install symlinks ----

if (( DRY_RUN )); then
    log_info "would run scripts/install-xdg.sh"
else
    bash "$SCRIPT_DIR/install-xdg.sh"
fi

# ---- final message ----

cat <<EOF

${GREEN}Migration staged.${NC} Review with:
    git status
    git diff --staged
Then commit:
    git commit -m "migrate to XDG layout"
Next:
    exec \$SHELL           # pick up ZDOTDIR
    bash scripts/verify.sh
Rollback if needed:
    git reset --hard HEAD
    tar xzf $backup_path -C "$DOTFILES_DIR"
EOF
