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
    alias rebuild="darwin-rebuild switch --flake $HOME/dotfiles/nix"
    ;;
  *)
    alias rebuild='echo "\x1b[31;1merror:\x1b[0m Must be NixOS or macOS."'
    ;;
esac

# Unset the OS variable so that it is not exposed in the session.
unset os

# ls alias.
# alias ls="ls -la"

# Initialize direnv.
eval "$(direnv hook zsh)"

# Initialize Starship for formatting.
eval "$(starship init zsh)"

# Start tmux.
if [ "$TMUX" = "" ]; then exec tmux; fi
