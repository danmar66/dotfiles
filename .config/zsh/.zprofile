# ~/.config/zsh/.zprofile — login-time init. Runs after .zshenv, before .zshrc.

# Prepend ~/.local/bin to PATH only if not already present.
case ":${PATH}:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Git: look for config under XDG (harmless even if file doesn't exist yet).
export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config"

# Vim: only set VIMINIT if an XDG vimrc actually exists.
[ -f "$XDG_CONFIG_HOME/vim/vimrc" ] && export VIMINIT="source $XDG_CONFIG_HOME/vim/vimrc"