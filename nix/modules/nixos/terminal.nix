{ pkgs, ... }:
{
  environment = {
    # Substitute GNOME Console for GNOME Terminal.
    gnome.excludePackages = [ pkgs.gnome-console ];

    systemPackages = with pkgs; [
      gnome-terminal
      starship
      tmux
    ];
  };

  programs.zsh.enable = true;
}
