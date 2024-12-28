{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    ../modules/fonts.nix
    ../modules/nixos/apps.nix
    ../modules/nixos/audio.nix
    ../modules/nixos/boot.nix
    ../modules/nixos/gnome.nix
    ../modules/nixos/locale.nix
    ../modules/nixos/printing.nix
    ../modules/nixos/terminal.nix
    ../modules/nix.nix
    ../modules/tools.nix
  ];

  # Boot configuration.
  # This was auto-generated and should not be changed manually.
  boot = {
    extraModulePackages = [];

    initrd = {
      availableKernelModules = [ "xhci_pci" "sr_mod" ];
      kernelModules = [];
    };

    kernelModules = [];
  };

  # File system configuration.
  # This was auto-generated and should not be changed manually.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/cc20244e-a7f1-4a62-9581-cf800fe175f4";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/E9B9-AEFA";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  # Indicates that this is a Parallels virtual machine.
  hardware = {
    graphics.enable = true;
    parallels.enable = true;
  };

  # Enable DHCP on all Ethernet and wireless interfaces.
  networking = {
    hostName = "ceres";
    useDHCP = lib.mkDefault true;
  };

  nixpkgs = {
    config.allowUnfreePredicate =
      pkg: builtins.elem (lib.getName pkg) [ "prl-tools" ];

    hostPlatform = lib.mkDefault "aarch64-linux";
  };

  # This was auto-generated and should not be changed manually.
  swapDevices = [];

  system.stateVersion = "24.11";

  users.users.jeff = {
    description = "Jeff Shelton";

    extraGroups = [
      "audio"
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
