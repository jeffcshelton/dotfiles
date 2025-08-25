# Hyprland desktop environment configuration.

{ inputs, pkgs, ... }:
{
  environment = {
    sessionVariables = {
      # Hint to Electron apps to use Wayland.
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";

      # Tell QT-based applications to use Wayland.
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };

    systemPackages = with pkgs; [
      # Enables screen brightness control (including dimming).
      brightnessctl

      # Clipboard manager for Wayland.
      clipse

      # Controls moniters as I2C devices.
      ddcutil

      # Notification daemon.
      dunst

      # Takes a screenshot of the specified area of the screen.
      # Chained with "grim" to take screenshots of selected regions.
      grim

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

      # Enables sending notifications through notify-send.
      libnotify

      # Allows for reading hardware temperatures.
      lm_sensors

      # Bluetooth manager in the absence of GNOME utilities.
      overskride

      # Enables Hyprland keybinds to control music playback.
      playerctl

      # Enables QT apps to use Wayland directly.
      qt5.qtwayland
      qt6.qtwayland

      # Application launcher.
      rofi-wayland

      # Allows selecting a portion of the screen.
      # Chained with "grim" to take screenshots of selected regions.
      slurp

      # Greet daemon.
      tuigreet

      # Top status bar.
      waybar

      # Wayland system clipboard.
      wl-clipboard
    ];
  };

  programs.hyprland = {
    enable = true;

    # Enables X11 apps to still run on a compatibility layer.
    xwayland.enable = true;
  };

  services = {
    dbus.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };
}
