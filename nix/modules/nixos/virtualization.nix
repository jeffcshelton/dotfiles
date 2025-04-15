# Packages and configuration related to virtualization and containers.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    docker-compose
    podman-compose
    podman-tui
  ];

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
}
