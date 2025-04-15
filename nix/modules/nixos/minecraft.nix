# Minecraft (including required Java) configuration.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ferium
    jre_minimal

    # The official Minecraft launcher for NixOS is broken.
    # Prism is an unofficial launcher that works fine.
    prismlauncher
  ];

  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 ];
  };
}
