# ~/.bashrc — thin wrapper. Bash doesn't read $XDG_CONFIG_HOME natively, so source it by hand.
# Tools like NVM that append to this file bypass XDG; move such blocks to
# $XDG_CONFIG_HOME/bash/bashrc if you notice them here.

: "${XDG_CONFIG_HOME:=$HOME/.config}"

if [ -r "$XDG_CONFIG_HOME/bash/bashrc" ]; then
    . "$XDG_CONFIG_HOME/bash/bashrc"
fi