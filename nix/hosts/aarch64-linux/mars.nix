{ inputs, pkgs, ... }:
{
  imports = [
    # General modules
    ../modules/dev.nix
    ../modules/neovim.nix
    ../modules/nix.nix
    ../modules/rust.nix
    ../modules/shell.nix
    ../modules/ssh.nix

    # NixOS modules
    ../modules/nixos/bluetooth.nix
    ../modules/nixos/debug.nix
    ../modules/nixos/kernel.nix
    ../modules/nixos/locale.nix

    # Server modules
    ../modules/nixos/server/git.nix
    ../modules/nixos/server/ssh.nix
    ../modules/nixos/server/tunnel.nix
    ../modules/nixos/server/website.nix

    # Users
    ../users/admin.nix

    # Hardware modules
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

  # Include packages specific to the Pi 4B.
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  # Networking configuration.
  networking = {
    hostName = "mars";
    networkmanager.enable = true;
  };

  # An overlay that allows default kernel modules to be excluded if they were
  # not compiled with this kernel version.
  #
  # This is necessary for image generation, as nixpkgs included a standard set
  # of kernel modules when bundling into an image, but some are not included or
  # necessary for the Raspberry Pi 4B (specifically sun4i-drm). This overlay is
  # a temporary workaround until that issue can be fixed.
  #
  # See: https://github.com/NixOS/nixpkgs/issues/154163
  # nixpkgs.overlays = [
  #   (final: super: {
  #     makeModulesClosure = modules:
  #       super.makeModulesClosure (modules // { allowMissing = true; });
  #   })
  # ];

  # It's necessary to disable sudo's password requirement for wheel users since
  # the primary user does not have a password.
  #
  # Without this, sudo will still prompt for a password but none will work.
  security.sudo.wheelNeedsPassword = false;

  # Cloudflare tunnel definition and rules.
  server.tunnels."2ef66204-58a9-4489-ba95-e1422803e192".ingress = {
    "shelton.one" = "http://localhost:80";
    "mars.shelton.one" = "ssh://localhost:22";
  };

  # The original Nix version installed on Mars.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "25.05";

  # Enable compressed RAM swap, as Mars is a low-memory device.
  zramSwap.enable = true;
}
