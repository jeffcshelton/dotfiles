# Packages and configuration related to the terminal.
#
# Much of the terminal configuration is specified through the Tmux config and
# the Neovim config. These are kept separate from Nix and symlinked into
# ~/.config using GNU Stow.

{ pkgs, ... }:
{
  environment = {
    # Substitute GNOME Console for Ghostty if using GNOME.
    gnome.excludePackages = [ pkgs.gnome-console ];

    systemPackages = with pkgs; [
      starship
      tmux
    ];
  };
}
