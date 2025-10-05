# Packages and configuration related to the terminal.
#
# Much of the terminal configuration is specified through the Tmux config and
# the Neovim config. These are kept separate from Nix and symlinked into
# ~/.config using GNU Stow.

{ isDarwin, isLinux, lib, pkgs, ... }:
lib.mkMerge [
  (lib.optionalAttrs isDarwin {
    # Ghostty is currently broken for Darwin targets on unstable.
    # See: https://github.com/NixOS/nixpkgs/issues/388984
    homebrew.casks = [ "ghostty" ];
  })

  (lib.optionalAttrs isLinux {
    environment = {
      environment.systemPackages = with pkgs; [
        ghostty
      ];

      # Substitute GNOME Console for Ghostty if using GNOME.
      gnome.excludePackages = [ pkgs.gnome-console ];
    };
  })
]
