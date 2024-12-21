{ pkgs, ... }:
{
  nix = {
    gc = {
      automatic = true;
      interval = {
        Hour = 0;
        Minute = 0;
        Weekday = 0;
     };

      options = "--delete-older-than 14d";
    };

    optimise.automatic = true;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;
}
