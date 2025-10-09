{ config, inputs, pkgs, ... }:
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

  disko.devices = {
    disk.main = {
      device = "/dev/sda";
      imageSize = "16G";
      type = "disk";

      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02";
          };

          ESP = {
            type = "EF00";
            size = "512M";
            content = {
              format = "vfat";
              mountOptions = [ "umask=0077" ];
              mountpoint = "/boot";
              type = "filesystem";
            };
          };

          root = {
            size = "100%";
            content = {
              format = "ext4";
              mountpoint = "/";
              type = "filesystem";
            };
          };
        };
      };
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

  age.secrets.system-key = {
    file = ../../secrets/keys/mars/system.pem.age;
    mode = "0600";
    owner = "root";
    group = "root";
  };

  services = {
    "portal-labs.cc".port = 7201;
    "shelton.one".port = 4390;
    openssh.hostKeys = [
      {
        type = "ed25519";
        path = config.age.secrets.system-key.path;
      }
    ];
  };

  # The original Nix version installed on Mars.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "25.05";

  # Enable compressed RAM swap, as Mars is a low-memory device.
  zramSwap.enable = true;
}
