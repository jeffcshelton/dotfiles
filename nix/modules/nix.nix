{ ... }:
{
  nix = {
    # Automatic garbage collection.
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    optimise.automatic = true;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;
}
