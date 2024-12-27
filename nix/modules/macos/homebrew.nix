{ ... }:
{
  # Universal Homebrew configuration for macOS machines.
  # This does not include any brews/casks/apps because those are per-module.
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };
}
