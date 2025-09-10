# Determine the operating system.
os="$(uname)"

if [ "$os" = "Linux" ] && [ -f /etc/NIXOS ]; then
  os="NixOS"
fi

# Rebuild alias.
# This alias must be constructed differently on macOS vs NixOS.
case "$os" in
  "NixOS")
    alias rebuild="sudo nixos-rebuild switch --flake $HOME/dotfiles/nix"
    ;;
  "Darwin")
    alias rebuild="sudo darwin-rebuild switch --flake $HOME/dotfiles/nix"
    ;;
  *)
    alias rebuild='echo "\x1b[31;1merror:\x1b[0m Must be NixOS or macOS."'
    ;;
esac

# Unset the OS variable so that it is not exposed in the session.
unset os

function expand {
  awk 'BEGIN {RS=""; ORS="\n\n"} {gsub(/\n/, " "); gsub(/ +/, " "); print}' $1
}

# ls alias.
alias ls="ls -la"

# Neovim alias to v.
alias v="nvim"

# Initialize direnv for dev environments.
eval "$(direnv hook zsh)"

# Initialize Starship for formatting.
eval "$(starship init zsh)"

# Initialize zoxide for smart cd.
eval "$(zoxide init zsh)"

# Start tmux.
if [[ -z "$TMUX" && -z "$SSH_CONNECTION" ]]; then exec tmux; fi
