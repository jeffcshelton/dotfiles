# Packages and configuration related to the terminal.
#
# Much of the terminal configuration is specified through the Tmux config and
# the Neovim config. These are kept separate from Nix and symlinked into
# ~/.config using GNU Stow.

{ isDarwin, isLinux, lib, pkgs, ... }:
lib.mkMerge [
  (lib.optionalAttrs isDarwin {
    environment.systemPackages = [ pkgs.ghostty-bin ];
  })

  (lib.optionalAttrs isLinux {
    environment = {
      systemPackages = [ pkgs.ghostty ];

      # Substitute GNOME Console for Ghostty if using GNOME.
      gnome.excludePackages = [ pkgs.gnome-console ];
    };
  })
]
