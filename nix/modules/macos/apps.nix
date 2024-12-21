{ self, pkgs, ... }:
{
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
}
