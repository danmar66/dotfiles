#!/usr/bin/env bash
# scripts/verify.sh — read-only XDG health check. Exit 0 on PASS, 1 on FAIL.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"

declare -i fails=0

ok()   { log_ok  "$*"; }
fail() { log_err "$*"; fails+=1; }

# realpath wrapper — portable resolve
_realpath() {
    local p=$1
    if command -v realpath >/dev/null 2>&1; then
        realpath "$p"
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' "$p"
    else
        # last resort: readlink -f (GNU only)
        readlink -f "$p"
    fi
}

check_env() {
    local name=$1 expected=$2
    local actual=${!name:-}
    if [[ "$actual" == "$expected" ]]; then
        ok "$name = $actual"
    else
        fail "$name: expected '$expected', got '$actual'"
    fi
}

check_symlink() {
    local path=$1
    if [[ ! -L "$path" ]]; then
        fail "not a symlink: $path"
        return
    fi
    local target
    target=$(readlink "$path")
    if [[ "$target" != "$DOTFILES_DIR"* ]]; then
        fail "symlink target outside repo: $path → $target"
        return
    fi
    if [[ ! -e "$path" ]]; then
        fail "broken symlink: $path → $target"
        return
    fi
    if [[ ! -s "$path" ]]; then
        fail "empty file via symlink: $path"
        return
    fi
    ok "symlink: $path → $target"
}

check_parses() {
    local shell=$1 path=$2
    if [[ ! -e "$path" ]]; then
        fail "missing file for $shell -n: $path"
        return
    fi
    if "$shell" -n "$path" 2>/dev/null; then
        ok "$shell -n $path"
    else
        fail "$shell -n failed: $path"
    fi
}

# 1-2. env vars (only meaningful in a shell that sourced .zshenv; warn if unset here)
log_info "--- env vars ---"
if [[ -n "${ZDOTDIR:-}" ]]; then
    check_env ZDOTDIR "$XDG_CONFIG_HOME/zsh"
else
    log_warn "ZDOTDIR not exported in this shell (run 'exec zsh' and retry)"
fi
if [[ -n "${HISTFILE:-}" ]]; then
    case "$HISTFILE" in
        "$XDG_STATE_HOME"/*) ok "HISTFILE = $HISTFILE" ;;
        *) fail "HISTFILE not under XDG_STATE_HOME: $HISTFILE" ;;
    esac
else
    log_warn "HISTFILE not exported in this shell (run 'exec zsh' and retry)"
fi

# 3-5. symlinks + target existence + non-empty
log_info "--- symlinks ---"
check_symlink "$HOME/.zshenv"
check_symlink "$HOME/.bashrc"
check_symlink "$HOME/.ideavimrc"
check_symlink "$XDG_CONFIG_HOME/zsh/.zshrc"
check_symlink "$XDG_CONFIG_HOME/zsh/.zprofile"
check_symlink "$XDG_CONFIG_HOME/bash/bashrc"

# 6-8. syntax checks
log_info "--- syntax ---"
check_parses zsh  "$XDG_CONFIG_HOME/zsh/.zshrc"
check_parses zsh  "$XDG_CONFIG_HOME/zsh/.zprofile"
check_parses bash "$XDG_CONFIG_HOME/bash/bashrc"

# 9. ideavim consistency
log_info "--- ideavim consistency ---"
home_ideavim="$HOME/.ideavimrc"
xdg_ideavim="$XDG_CONFIG_HOME/ideavim/ideavimrc"
if [[ -e "$home_ideavim" && -e "$xdg_ideavim" ]]; then
    if [[ "$(_realpath "$home_ideavim")" == "$(_realpath "$xdg_ideavim")" ]]; then
        ok "~/.ideavimrc and .config/ideavim/ideavimrc resolve to same file"
    else
        fail "~/.ideavimrc and .config/ideavim/ideavimrc differ"
    fi
else
    log_warn "ideavim files missing; skipping consistency check"
fi

# 10. placeholder dirs (warn only)
log_info "--- placeholder dirs ---"
for d in "$XDG_CONFIG_HOME/vim" "$XDG_CONFIG_HOME/nvim"; do
    [[ -d "$d" ]] && ok "exists: $d" || log_warn "missing: $d"
done

echo
if (( fails == 0 )); then
    log_ok "PASS"
    exit 0
else
    log_err "FAIL: $fails check(s) failed"
    exit 1
fi