{ isDarwin, lib, ... }:
lib.optionalAttrs isDarwin {
  system.defaults.dock = {
    # The Dock can't be removed outright, so it auto-hides behind a delay long
    # enough that it never appears. The apps below are kept in case it is
    # brought back.
    autohide = true;
    autohide-delay = 1000.0;

    # The apps displayed on the dock, in order from left to right.
    persistent-apps = [
      "/System/Applications/Apps.app"
      "/System/Applications/Calendar.app"
      "/System/Applications/Mail.app"
      "/System/Applications/Messages.app"
      "/Applications/Nix Apps/Firefox.app"
      "/Applications/Nix Apps/Spotify.app"
      "/Applications/Nix Apps/Notion.app"
      "/Applications/Pixelmator Pro.app"
      "/System/Applications/System Settings.app"
      "/Applications/Nix Apps/Ghostty.app"
    ];

    show-recents = false;
  };
}
