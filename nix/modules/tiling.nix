# Tiling desktop environment configuration: Hyprland on Linux, and AeroSpace
# with SketchyBar and JankyBorders styled after it on macOS.
#
# The AeroSpace, SketchyBar, and JankyBorders configs live in ~/.config and are
# read from there, since none of them are given config paths.

{ config, isDarwin, isLinux, lib, pkgs, unstable, ... }:
lib.mkMerge [
  (lib.optionalAttrs isDarwin {
    # Top status bar, in place of the macOS menu bar.
    services.sketchybar = {
      enable = true;
      extraPackages = [ pkgs.jq ];
    };

    environment.systemPackages = [
      pkgs.jankyborders

      # Tiling window manager. Starts itself at login (see aerospace.toml).
      unstable.aerospace
    ];

    # Window borders. The nix-darwin module always passes options on the
    # command line, which would bypass ~/.config/borders/bordersrc, so the
    # agent is defined here instead.
    launchd.user.agents.jankyborders = {
      path = [ pkgs.jankyborders config.environment.systemPath ];
      serviceConfig = {
        ProgramArguments = [ "${pkgs.jankyborders}/bin/borders" ];
        KeepAlive = true;
        RunAtLoad = true;
      };
    };

    system.defaults = {
      NSGlobalDomain = {
        # Hide the menu bar so SketchyBar can take its place.
        _HIHideMenuBar = true;

        # Skip the window open/close animations.
        NSAutomaticWindowAnimationsEnabled = false;
      };

      # Hide desktop icons, as on Hyprland.
      finder.CreateDesktop = false;

      # Group windows by app in Mission Control, since AeroSpace parks hidden
      # windows in a corner of the screen where they'd otherwise be tiny.
      dock.expose-group-apps = true;

      # AeroSpace recommends turning off "Displays have separate Spaces".
      spaces.spans-displays = true;

      WindowManager = {
        # Clicking the wallpaper shouldn't sweep every window aside.
        EnableStandardClickToShowDesktop = false;

        # Stage Manager conflicts with tiling.
        GloballyEnabled = false;
      };
    };
  })

  (lib.optionalAttrs isLinux {
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
        rose-pine-hyprcursor

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
        rofi

        # Allows selecting a portion of the screen.
        # Chained with "grim" to take screenshots of selected regions.
        slurp

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
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.hyprland}/bin/start-hyprland";
          user = "greeter";
        };
      };
    };
  })
]
