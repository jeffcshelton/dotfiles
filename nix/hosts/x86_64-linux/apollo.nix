{ inputs, pkgs, ... }:
{
  imports = [
    # General modules
    ../../modules/agents.nix
    ../../modules/debug.nix
    ../../modules/dev.nix
    ../../modules/locale.nix
    ../../modules/neovim.nix
    ../../modules/net.nix
    ../../modules/nix.nix
    ../../modules/shell.nix
    ../../modules/ssh.nix
    ../../modules/wireguard.nix

    # Server modules
    ../../modules/server/cache.nix
    ../../modules/server/gitea.nix
    ../../modules/server/ssh.nix
    ../../modules/server/tunnel.nix
    ../../modules/server/shelton-one.nix

    # Users
    ../../users/admin.nix
    ../../users/jeff.nix

    # Hardware modules
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
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

  # The whole internal disk is partitioned by nixos-anywhere during installation,
  # and the resulting file systems are mounted from this same layout.
  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
    type = "disk";

    content = {
      type = "gpt";

      partitions = {
        boot = {
          size = "512M";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            extraArgs = [ "-n" "BOOT" ];
            mountpoint = "/boot";
            mountOptions = [ "fmask=0077" "dmask=0077" ];
          };
        };

        root = {
          size = "100%";

          content = {
            type = "filesystem";
            format = "ext4";
            extraArgs = [ "-L" "nixos" ];
            mountpoint = "/";
          };
        };
      };
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;

    # Wi-Fi and Bluetooth firmware is extracted from Apple's macOS recovery
    # image. Only the firmware is taken from the nixos-hardware T2 module: its
    # patched kernel serves the internal keyboard, trackpad, audio, and fans,
    # none of which a headless server needs, and is not binary-cached. The
    # stock kernel already supports the Wi-Fi chip and NVMe drive.
    firmware = [
      (pkgs.callPackage "${inputs.nixos-hardware}/apple/t2/pkgs/brcm-firmware" {
        version = "sonoma";
      })
    ];
  };

  # It's necessary to disable sudo's password requirement for wheel users since
  # the primary user does not have a password.
  #
  # Without this, sudo will still prompt for a password but none will work.
  security.sudo.wheelNeedsPassword = false;

  # Cloudflare tunnel for public HTTP. The router forwards only WireGuard, so
  # SSH is reachable from the home LAN and over the VPN, never publicly.
  server.cloudflare = {
    enable = true;
    tunnels."06684310-6ec1-40a5-ab96-3f31cfe4d185".ingress = {
      "git.shelton.one" = "http://localhost:3000";
      "shelton.one" = "http://localhost:4390";
    };
  };

  services."shelton.one".port = 4390;

  # Apollo is headless, so jeff is a shell account without desktop apps.
  jeff.desktop = false;

  # Jeff's dotfiles are cloned from the local Gitea on first activation, which
  # only works once Gitea has registered jeff's key.
  systemd.services.home-manager-jeff.after = [ "gitea-admin-setup.service" ];

  # The display has been removed, so the lid sensor must never suspend Apollo.
  services.logind.settings.Login.HandleLidSwitch = "ignore";

  # The original Nix version installed on Apollo.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "26.05";
}
