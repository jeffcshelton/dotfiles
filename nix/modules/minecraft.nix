{ lib, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.jre_minimal ];

  # Install Minecraft and CurseForge via Homebrew if running macOS.
  homebrew.casks = lib.mkIf (pkgs.stdenv.isDarwin) [
    "curseforge"
    "minecraft"
  ];
}
