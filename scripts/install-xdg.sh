#!/usr/bin/env bash
# scripts/install-xdg.sh — create all symlinks for the XDG layout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME

# Preflight: the installer can only run after the XDG layout exists in the repo.
if [[ ! -d "$DOTFILES_DIR/.config" ]]; then
    log_err "install-xdg.sh requires the XDG layout. Run scripts/migrate-xdg.sh first."
    exit 1
fi

log_info "Installing from: $DOTFILES_DIR"

# XDG base dirs
mkdir -p "$XDG_CONFIG_HOME" "$HOME/.local/bin" "$XDG_DATA_HOME" "$XDG_STATE_HOME/zsh"

# Track counters. link_file's output already distinguishes ok/info/warn;
# we just count the number of link_file invocations.
declare -i links=0

do_link() {
    link_file "$1" "$2"
    links+=1
}

do_link "$DOTFILES_DIR/.zshenv"                   "$HOME/.zshenv"
do_link "$DOTFILES_DIR/.bashrc"                   "$HOME/.bashrc"
do_link "$DOTFILES_DIR/.config/zsh/.zshrc"        "$XDG_CONFIG_HOME/zsh/.zshrc"
do_link "$DOTFILES_DIR/.config/zsh/.zprofile"     "$XDG_CONFIG_HOME/zsh/.zprofile"
do_link "$DOTFILES_DIR/.config/bash/bashrc"       "$XDG_CONFIG_HOME/bash/bashrc"
do_link "$DOTFILES_DIR/.config/ideavim/ideavimrc" "$HOME/.ideavimrc"

log_ok "install-xdg.sh done: processed $links link(s)"