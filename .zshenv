# ~/.zshenv — only zsh file that stays in $HOME. Sets ZDOTDIR so everything else lives under XDG.

# XDG base dirs, defensive defaults
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME XDG_STATE_HOME

# Redirect zsh config into XDG
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# History under $XDG_STATE_HOME (ensure dir exists)
export HISTFILE="$XDG_STATE_HOME/zsh/history"
[ -d "$XDG_STATE_HOME/zsh" ] || mkdir -p "$XDG_STATE_HOME/zsh"

# NVM: expose the latest installed Node on PATH for every zsh (login and non-login).
# Kept in .zshenv (not .zprofile) so tmux/IDE subshells also see it.
if [ -d "$HOME/.nvm/versions/node" ]; then
    NVM_LATEST=$(ls -1 "$HOME/.nvm/versions/node" 2>/dev/null | sort -V | tail -n1)
    [ -n "$NVM_LATEST" ] && export PATH="$HOME/.nvm/versions/node/$NVM_LATEST/bin:$PATH"
    unset NVM_LATEST
fi
