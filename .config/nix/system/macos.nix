{ self, pkgs, ... }:
{
  imports = [ ./common.nix ];

  # Homebrew brews and casks.
  homebrew = {
    enable = true;

    # Casks from Homebrew.
    casks = [
      "alacritty"
      "discord"
      "firefox"
      "iterm2"
      "notion"
      "prusaslicer"
      "spotify"
      "wireshark"
    ];

    # Apps from the App Store.
    masApps = {
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Word" = 462054704;
      "OneDrive" = 823766827;
      "Pixelmator Pro" = 1289583905;
      "Windows App" = 1295203466;
      "iMovie" = 408981434;
    };

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };

  # Launch the Nix daemon.
  services.nix-daemon.enable = true;

  system = {
    defaults = {
      controlcenter = {
        AirDrop = false;
        BatteryShowPercentage = true;
        Bluetooth = true;
        Display = false;
        FocusModes = false;
        NowPlaying = false;
        Sound = true;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.0;

        # The apps displayed on the dock, in order from left to right.
        persistent-apps = [
          "/System/Applications/Launchpad.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Mail.app"
          "/System/Applications/Messages.app"
          "/Applications/Firefox.app"
          "/Applications/Spotify.app"
          "/Applications/Notion.app"
          "/Applications/Microsoft Teams.app"
          "/Applications/Pixelmator Pro.app"
          "/System/Applications/System Settings.app"
          "/Applications/iTerm.app"
        ];

        show-recents = false;
      };
    };

    stateVersion = 5;
  };
}
