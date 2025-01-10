{ lib, pkgs, ... }:
{
  imports = [
    ../modules/fonts.nix
    ../modules/nixos/apps.nix
    ../modules/nixos/audio.nix
    ../modules/nixos/boot.nix
    ../modules/nixos/cad.nix
    ../modules/nixos/firefox.nix
    ../modules/nixos/fpga.nix
    ../modules/nixos/gnome.nix
    ../modules/nixos/hyprland.nix
    ../modules/nixos/locale.nix
    ../modules/nixos/minecraft.nix
    ../modules/nixos/photo.nix
    ../modules/nixos/postgres.nix
    ../modules/nixos/printing.nix
    ../modules/nixos/rgb.nix
    ../modules/nixos/terminal.nix
    ../modules/nixos/vpn.nix
    ../modules/neovim.nix
    ../modules/nix.nix
    ../modules/tools.nix
  ];

  boot = {
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "sd_mod"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];

      kernelModules = [ ];

      luks.devices = {
        "luks-508ef57e-97a2-444d-9a3d-058e17af064b" = {
          device = "/dev/disk/by-uuid/508ef57e-97a2-444d-9a3d-058e17af064b";
        };

        "luks-53965f7e-bca6-404b-a905-6e8ba2d91f8d" = {
          device = "/dev/disk/by-uuid/53965f7e-bca6-404b-a905-6e8ba2d91f8d";
        };
      };
    };

    kernelModules = [
      # AMD-specific module enabling virtualization.
      "kvm-amd"

      # Support for the motherboard chip that provides temperature sensing.
      "nct6775"
    ];

    # Substitute the LTS kernel with the newest release.
    kernelPackages = pkgs.linuxPackages_latest;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/633935da-4489-43f6-9bdd-2ff58e6aa9ea";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/8A4C-2F93";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  hardware = {
    # Enable microcode updates to the AMD CPU.
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;

    # Enables I2C control for controlling external display brightness.
    i2c.enable = true;
  };

  # Networking configuration.
  networking = {
    hostName = "jupiter";
    networkmanager.enable = true;

    # Enables DHCP on all interfaces.
    useDHCP = lib.mkDefault true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  swapDevices = [
    { device = "/dev/disk/by-uuid/203490f0-236f-496c-a686-1991051a8556"; }
  ];

  # The original Nix version installed on Jupiter.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "24.11";

  users.users.jeff = {
    description = "Jeff Shelton";

    extraGroups = [
      "audio"
      "i2c"
      "input"
      "networkmanager"
      "seat"
      "video"
      "wheel"
    ];

    home = "/home/jeff";
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}
