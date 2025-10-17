{ inputs, lib, pkgs, ... }:
let
  systemKey = builtins.getEnv "SYSTEM_KEY";
  systemKeyFile = pkgs.writeText "ssh_host_ed25519_key" systemKey;
in
{
  imports = [
    # General modules
    ../../modules/bluetooth.nix
    ../../modules/debug.nix
    ../../modules/dev.nix
    ../../modules/kernel.nix
    ../../modules/locale.nix
    ../../modules/neovim.nix
    ../../modules/nix.nix
    ../../modules/rust.nix
    ../../modules/shell.nix
    ../../modules/ssh.nix

    # Server modules
    ../../modules/server/git.nix
    ../../modules/server/ssh.nix
    ../../modules/server/tunnel.nix
    ../../modules/server/portal-labs-cc.nix
    ../../modules/server/shelton-one.nix

    # Users
    ../../users/admin.nix

    # Hardware modules
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  boot = {
    growPartition = true;

    kernelModules = [
      "gpio-dev"
      "i2c-dev"
      "spi-dev"
      "spidev"
    ];

    kernelPackages = pkgs.linuxPackages_6_6;

    loader = {
      timeout = 0;
      generic-extlinux-compatible.enable = true;
    };
  };

  # Disable consoles because there is no display.
  console.enable = false;

  fileSystems = { # lib.mkDefault {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      autoResize = true;
    };

    "/boot" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  # Networking configuration.
  networking = {
    hostName = "mars";
    networkmanager.enable = true;
  };

  # It's necessary to disable sudo's password requirement for wheel users since
  # the primary user does not have a password.
  #
  # Without this, sudo will still prompt for a password but none will work.
  security.sudo.wheelNeedsPassword = false;

  # Cloudflare tunnel definition and rules.
  server.tunnels."23637481-8e77-4e1d-825b-824831e929b1".ingress = {
    "mars.shelton.one" = "ssh://localhost:22";
    "portal-labs.cc" = "http://localhost:7201";
    "shelton.one" = "http://localhost:4390";
  };

  environment.etc = {
    "ssh/ssh_host_ed25519_key" = {
      mode = "0600";
      source = systemKeyFile;
    };
  };

  services = {
    "portal-labs.cc".port = 7201;
    "shelton.one".port = 4390;
  };

  # The original Nix version installed on Mars.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "25.05";

  # Enable compressed RAM swap, as Mars is a low-memory device.
  zramSwap.enable = true;
}
