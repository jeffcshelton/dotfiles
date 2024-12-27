{ lib, pkgs, ... }:
{
  nix = {
    # Automatic garbage collection.
    gc = {
      automatic = true;

      # NixOS and nix-darwin prefer different styles for date configuration.
      dates = lib.mkIf pkgs.stdenv.hostPlatform.isLinux "weekly";
      interval = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
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
  services.nix-daemon.enable = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin true;
}
