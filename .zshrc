# Aliases.
alias rebuild="darwin-rebuild switch --flake $HOME/dotfiles/.config/nix"

# Initialize direnv.
eval "$(direnv hook zsh)"

# Initialize Starship for formatting.
eval "$(starship init zsh)"

# Start tmux.
if [ "$TMUX" = "" ]; then exec tmux; fi
