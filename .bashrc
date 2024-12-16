#!/usr/bin/env bash

if [ -z "$TMUX" ]; then
  exec tmux
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Set aliases
alias ls="ls -la"
alias open="xdg-open"
alias v="nvim"
alias vi="nvim"
alias vim="nvim"


# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH
