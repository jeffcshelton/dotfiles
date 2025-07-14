#!/bin/sh

# TODO: This script completely does not work right now. Fix it.

# Determine the operating system.
os=$(uname)

# Check if the operating system is NixOS to differentiate from other distros.
if [ "$os" = "Linux" ] && [ -f /etc/NIXOS ]; then
  os="NixOS"
fi

# Check that the operating system is supported.
if [ "$os" != "NixOS" ] && [ "$os" != "Darwin" ]; then
  echo "\x1b[31;1merror:\x1b[0m Only macOS and NixOS are supported."
  exit 1
fi

# Check that Nix is installed.
if ! command -v nix > /dev/null 2>&1; then
  echo "\x1b[31;1merror:\x1b[0m Nix not installed."
  echo "Install Nix to proceed with the installation."
  exit 1
fi

# Check that Homebrew is not installed on macOS.
if [ "$os" = "Darwin" ] && command -v brew > /dev/null 2>&1; then
  echo "\x1b[31;1merror:\x1b[0m Homebrew must not be pre-installed."
  echo "Remove Homebrew and re-run the script to proceed with the installation."
  exit 1
fi

# Clone the dotfiles repository if it does not already exist.
if [ ! -d "$HOME/dotfiles" ]; then
  clone="git clone https://github.com/jeffcshelton/dotfiles.git $HOME/dotfiles"
  nix-shell -p git --run "$clone"

  if [ $? -ne 0 ]; then
    echo "\x1b[31;1merror:\x1b[0m Failed to clone the repository."
    exit 1
  fi
fi

# Collect all the host names from the configuration files.
find "$HOME/dotfiles/nix/hosts" -type f | while read -r file; do
  file="$(basename "$file")"
  hosts="$hosts${file%.*} "
done

echo "Choose host:"
select hostname in $hosts; do
  if [ -n "$hostname" ]; then
    break
  fi
done

case "$os" in
  "NixOS")
    sudo nix-rebuild switch \
      --flake "$HOME/dotfiles/nix#$hostname" \
      --experimental-features "flakes"
    ;;
  "Darwin")
      darwin-rebuild switch \
        --flake "$HOME/dotfiles/nix#$hostname" \
        --experimental-features "flakes"
    ;;
esac

cd "$HOME/dotfiles"

if stow .; then
  echo "\x1b[31;1merror:\x1b[0m Failed to stow."
  exit 1
fi
