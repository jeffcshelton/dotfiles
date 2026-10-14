{ inputs, lib, pkgs, ... }:
{
  imports = [
    # General modules
    ../../modules/debug.nix
    ../../modules/dev.nix
    ../../modules/kernel.nix
    ../../modules/locale.nix
    ../../modules/neovim.nix
    ../../modules/nix.nix
    ../../modules/rust.nix
    ../../modules/shell.nix
    ../../modules/ssh.nix
    ../../modules/tailscale.nix

    # Server modules
    ../../modules/server/ssh.nix

    # Users
    ../../users/admin.nix

    # Hardware modules
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

    # Use the latest mainline kernel, which is cached, over the downstream RPi
    # kernel, so drivers are developed against current upstream.
    kernelPackages = pkgs.linuxPackages_latest;

    loader.generic-extlinux-compatible = {
      configurationLimit = 1;
      enable = true;
    };
  };

  # Disable console because there is no display.
  console.enable = false;

  # Include packages specific to the Pi 4B.
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;

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

  # It's necessary to disable sudo's password requirement for wheel users since
  # the primary user does not have a password.
  #
  # Without this, sudo will still prompt for a password but none will work.
  security.sudo.wheelNeedsPassword = false;

  # The original Nix version installed on Venus.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "25.05";

  # Enable compressed RAM swap, as Mars is a low-memory device.
  zramSwap.enable = true;
}
