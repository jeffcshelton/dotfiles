{ isDarwin, lib, ... }:
lib.optionalAttrs isDarwin {
  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;

    # The apps displayed on the dock, in order from left to right.
    persistent-apps = [
      "/System/Applications/Launchpad.app"
      "/System/Applications/Calendar.app"
      "/System/Applications/Mail.app"
      "/System/Applications/Messages.app"
      "/Applications/Nix Apps/Firefox.app"
      "/Applications/Nix Apps/Spotify.app"
      "/Applications/Nix Apps/Notion.app"
      "/Applications/Pixelmator Pro.app"
      "/System/Applications/System Settings.app"
      "/Applications/Ghostty.app"
    ];

    show-recents = false;
  };
}
