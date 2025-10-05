# Packages and configuration related to virtualization and containers.

{ isLinux, lib, pkgs, ... }:
lib.mkMerge [
  {
    environment.systemPackages = with pkgs; [
      docker-compose
      podman-compose
      podman-tui
    ];
  }

  (lib.optionalAttrs isLinux {
    virtualisation = {
      # Enable Docker.
      docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };

      # Enable Podman (general Docker replacement).
      podman = {
        defaultNetwork.settings.dns_enabled = true;
        enable = true;
      };
    };
  })
]
