# Minecraft (including required Java) configuration.

{ isDarwin, isLinux, lib, pkgs, ... }:
lib.mkMerge [
  {
    environment.systemPackages = with pkgs; [
      ferium
      jre_minimal
    ];
  }

  (lib.optionalAttrs isDarwin {
    homebrew.casks = [
      "curseforge"
      "minecraft"
    ];
  })

  (lib.optionalAttrs isLinux {
    environment.systemPackages = with pkgs; [
      # The official Minecraft launcher for NixOS is broken.
      # Prism is an unofficial launcher that works fine.
      prismlauncher
    ];

    # Allow ports for serving LAN servers.
    networking.firewall = {
      allowedTCPPorts = [ 25565 ];
      allowedUDPPorts = [ 25565 ];
    };
  })
]
