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
      cores = 0;

      # Enable flakes.
      experimental-features = [ "nix-command" "flakes" ];

      # Use all cores to execute flake build steps in parallel.
      max-jobs = "auto";

      trusted-users = [ "root" "jeff" ];
    };
  };

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;
}
