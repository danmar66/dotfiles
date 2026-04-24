# scripts/lib/common.sh — shared bash helpers. Sourced, not executed.
# Safe to source multiple times and under `set -euo pipefail` in the caller.

if [[ -z "${_DOTFILES_COMMON_SH_LOADED:-}" ]]; then
    _DOTFILES_COMMON_SH_LOADED=1

    readonly RED=$'\033[0;31m'
    readonly GREEN=$'\033[0;32m'
    readonly YELLOW=$'\033[1;33m'
    readonly BLUE=$'\033[0;34m'
    readonly NC=$'\033[0m'

    # Repo root = parent of scripts/, portable (no readlink -f).
    _common_sh_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    readonly DOTFILES_DIR="$_common_sh_path"
    unset _common_sh_path
fi

log_info() { printf '%b➜%b %s\n' "$BLUE" "$NC" "$*"; }
log_ok()   { printf '%b✓%b %s\n' "$GREEN" "$NC" "$*"; }
log_warn() { printf '%b⚠%b %s\n' "$YELLOW" "$NC" "$*"; }
log_err()  { printf '%b✗%b %s\n' "$RED" "$NC" "$*" >&2; }

backup_file() {
    local path=$1
    local backup="${path}.backup.$(date +%s)"
    mv "$path" "$backup"
    printf '%s\n' "$backup"
}

require_cmd() {
    local cmd=$1
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_err "required command not found on PATH: $cmd"
        exit 1
    fi
}

link_file() {
    local src=$1
    local dst=$2

    if [[ ! -e "$src" ]]; then
        log_err "source does not exist: $src"
        return 1
    fi

    local dst_dir
    dst_dir=$(dirname "$dst")
    if [[ ! -d "$dst_dir" ]]; then
        mkdir -p "$dst_dir"
    fi

    if [[ -L "$dst" ]]; then
        if [[ "$(readlink "$dst")" == "$src" ]]; then
            log_ok "already linked: $dst"
            return 0
        fi
        rm "$dst"
        ln -s "$src" "$dst"
        log_info "updated symlink: $dst"
        return 0
    fi

    if [[ -e "$dst" ]]; then
        local backup
        backup=$(backup_file "$dst")
        log_warn "backed up existing: $dst → $backup"
    fi

    ln -s "$src" "$dst"
    log_ok "linked: $dst → $src"
}
