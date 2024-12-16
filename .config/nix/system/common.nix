{ pkgs, ... }:
{
  # Base packages that should exist throughout the system, not just for a
  # single user.
  environment.systemPackages = with pkgs; [ git curl ];

  # Fonts.
  fonts.packages = [
    pkgs.nerd-fonts.caskaydia-mono
  ];

  # Enable flakes and nix commands across the system.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree Nix packages.
  nixpkgs.config.allowUnfree = true;
}
