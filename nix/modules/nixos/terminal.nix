{ pkgs, ... }:
{
  environment = {
    # Substitute GNOME Console for Ghostty.
    gnome.excludePackages = [ pkgs.gnome-console ];

    systemPackages = with pkgs; [
      ghostty
      starship
      tmux
    ];
  };

  programs.zsh.enable = true;
}
