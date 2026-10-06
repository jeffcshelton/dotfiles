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

      extra-substituters = [
        "https://cache.numtide.com"
        "https://nix-community.cachix.org"
      ];

      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [ "root" "jeff" ];
    };
  };

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;
}
