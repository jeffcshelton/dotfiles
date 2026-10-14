{ inputs, pkgs, modulesPath, ... }:
{
  imports = [
    # General modules
    ../../modules/bluetooth.nix
    ../../modules/debug.nix
    ../../modules/kernel.nix
    ../../modules/locale.nix
    ../../modules/net.nix
    ../../modules/nix.nix
    ../../modules/ssh.nix
    ../../modules/tailscale.nix

    # Server modules
    ../../modules/server/ssh.nix

    # Users
    ../../users/admin.nix

    # Hardware modules
    inputs.agenix.nixosModules.default
    inputs.nixos-hardware.nixosModules.raspberry-pi-4

    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  boot = {
    growPartition = true;

    kernelModules = [
      "gpio-dev"
      "i2c-dev"
      "spi-dev"
      "spidev"
    ];

    kernelPackages = pkgs.linuxPackages;

    loader = {
      timeout = 0;
      generic-extlinux-compatible.enable = true;
    };
  };

  # Mars is normally headless; use UART only when physical boot diagnostics are needed.
  console.enable = false;

  fileSystems = {
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

  sdImage = {
    compressImage = false;
    firmwareSize = 512;
  };

  # The nixos-hardware Pi module populates the firmware partition itself.
  # Explicitly chainload U-Boot so the Pi firmware can reach extlinux on the
  # ext4 root partition.
  hardware.raspberry-pi.firmware.uboot.enable = true;

  # It's necessary to disable sudo's password requirement for wheel users since
  # the primary user does not have a password.
  #
  # Without this, sudo will still prompt for a password but none will work.
  security.sudo.wheelNeedsPassword = false;

  # The original Nix version installed on Mars.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "25.05";

  # Enable compressed RAM swap, as Mars is a low-memory device.
  zramSwap.enable = true;
}
