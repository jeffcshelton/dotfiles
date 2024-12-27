{ pkgs, ... }:
{
  # Include the Java runtime.
  environment.systemPackages = [ pkgs.jre_minimal ];

  # Install Minecraft and CurseForge via Homebrew if running macOS.
  homebrew.casks = [
    "curseforge"
    "minecraft"
  ];
}
