{ inputs, pkgs, ... }:
{
  environment = {
    sessionVariables = {
      # Hint to Electron apps to use Wayland.
      NIXOS_OZONE_WL = "1";

      # Tell QT-based applications to use Wayland.
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };

    systemPackages = with pkgs; [
      # Terminal.
      alacritty

      # Enables screen brightness control (including dimming).
      brightnessctl

      # Notification daemon.
      dunst

      # Manages the cursor.
      hyprcursor

      # Idle daemon.
      hypridle

      # Enables screen locking without logging out.
      hyprlock

      # Wallpaper daemon.
      hyprpaper

      # Lightweight color picker.
      hyprpicker

      # Rose Pine themed cursor.
      inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default

      # Enables Hyprland keybinds to control music playback.
      playerctl

      # Enables QT apps to use Wayland directly.
      qt5.qtwayland
      qt6.qtwayland

      # Application launcher.
      rofi-wayland

      # Top status bar.
      waybar
    ];
  };

  programs.hyprland = {
    enable = true;

    # Enables X11 apps to still run on a compatibility layer.
    xwayland.enable = true;
  };
}
