{ inputs, ... }:
{
  imports = [
    # General modules
    ../../modules/debug.nix
    ../../modules/locale.nix
    ../../modules/net.nix
    ../../modules/nix.nix
    ../../modules/ssh.nix
    ../../modules/tailscale.nix

    # Server modules
    ../../modules/server/gitea.nix
    ../../modules/server/ssh.nix
    ../../modules/server/tunnel.nix
    ../../modules/server/shelton-one.nix

    # Users
    ../../users/admin.nix

    # Hardware modules
    inputs.agenix.nixosModules.default
    inputs.nixos-hardware.nixosModules.apple-t2
  ];

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "sd_mod"
      "thunderbolt"
      "usb_storage"
      "usbhid"
      "xhci_pci"
    ];

    kernelModules = [ "kvm-intel" ];

    loader = {
      # Apple's firmware boots the fallback EFI/BOOT/BOOTX64.EFI path, and
      # writing NVRAM boot entries through the T2 is unreliable.
      efi.canTouchEfiVariables = false;

      systemd-boot = {
        configurationLimit = 10;
        enable = true;
      };

      timeout = 1;
    };
  };

  # Partitions are labeled during installation rather than referenced by UUID.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  hardware = {
    # Wi-Fi and Bluetooth firmware is extracted from Apple's macOS recovery image.
    apple-t2.firmware.enable = true;

    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

  # It's necessary to disable sudo's password requirement for wheel users since
  # the primary user does not have a password.
  #
  # Without this, sudo will still prompt for a password but none will work.
  security.sudo.wheelNeedsPassword = false;

  # Cloudflare tunnel for public HTTP. SSH is reachable only over Tailscale.
  server.cloudflare = {
    enable = true;
    tunnels."06684310-6ec1-40a5-ab96-3f31cfe4d185".ingress = {
      "git.shelton.one" = "http://localhost:3000";
      "shelton.one" = "http://localhost:4390";
    };
  };

  services."shelton.one".port = 4390;

  # The display has been removed, so the lid sensor must never suspend Apollo.
  services.logind.settings.Login.HandleLidSwitch = "ignore";

  # The original Nix version installed on Apollo.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "26.05";
}
