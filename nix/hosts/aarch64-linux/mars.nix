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

    # Server modules
    ../../modules/server/gitea.nix
    ../../modules/server/ssh.nix
    ../../modules/server/tunnel.nix
    ../../modules/server/shelton-one.nix

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

    kernelPackages = pkgs.linuxPackages_6_6;

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

  # Cloudflare tunnel definition and rules.
  server.cloudflare = {
    enable = true;
    tunnels."06684310-6ec1-40a5-ab96-3f31cfe4d185".ingress = {
      "git.shelton.one" = "http://localhost:3000";
      "ssh.git.shelton.one" = "ssh://localhost:2223";
      "mars.shelton.one" = "ssh://localhost:22";
      "shelton.one" = "http://localhost:4390";
    };
  };

  services."shelton.one".port = 4390;

  # The original Nix version installed on Mars.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "25.05";

  # Enable compressed RAM swap, as Mars is a low-memory device.
  zramSwap.enable = true;
}
