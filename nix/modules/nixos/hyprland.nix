{ pkgs, ... }:
{
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    systemPackages = with pkgs; [
      dunst
      kitty
      hyprcursor
      hypridle
      hyprlock
      hyprpaper
      hyprpicker
      pyprland
      qt6.qtwayland
      rofi-wayland
      seatd
      waybar
      wlogout
      wlrctl
      wtype
      xdg-utils
    ];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services = {
    seatd.enable = true;

    xserver = {
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      enable = true;

      xkb = {
        layout = "us";
        options = "grp:alt_shift_toggle";
      };
    };
  };
}
