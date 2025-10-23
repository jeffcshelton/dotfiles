# Configuration of the Nix package manager.

{ ... }:
{
  nix = {
    # Automatic garbage collection.
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    optimise.automatic = true;

    settings = {
      # Use all cores by default _within_ the build steps of flakes.
      cores = 8;

      # Enable flakes.
      experimental-features = [ "nix-command" "flakes" ];

      # Use all cores to execute flake build steps in parallel.
      max-jobs = "auto";

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [ "root" "jeff" ];
    };
  };

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;
}
