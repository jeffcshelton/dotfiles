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
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "jeff" ];
    };
  };

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;
}
