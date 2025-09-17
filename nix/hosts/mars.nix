{ lib, pkgs, ... }:
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
  ];

  boot = {
    growPartition = true;

    kernelModules = [
      "gpio-dev"
      "i2c-dev"
      "spi-dev"
      "spidev"
    ];

    loader.generic-extlinux-compatible = {
      enable = true;
      configurationLimit = 1;
    };
  };

  # Disable consoles because there is no display.
  console.enable = false;

  # Include packages specific to the Pi 4B.
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  hardware = {
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
      fkms-3d.enable = true;
    };
  };

  fileSystems = lib.mkDefault {
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

  # An overlay that allows default kernel modules to be excluded if they were
  # not compiled with this kernel version.
  #
  # This is necessary for image generation, as nixpkgs included a standard set
  # of kernel modules when bundling into an image, but some are not included or
  # necessary for the Raspberry Pi 4B (specifically sun4i-drm). This overlay is
  # a temporary workaround until that issue can be fixed.
  #
  # See: https://github.com/NixOS/nixpkgs/issues/154163
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = modules:
        super.makeModulesClosure (modules // { allowMissing = true; });
    })
  ];

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
