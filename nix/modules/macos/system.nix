{ pkgs, ... }:
{
  # macOS system-level configuration.
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
