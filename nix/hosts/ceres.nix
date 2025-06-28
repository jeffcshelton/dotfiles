{ inputs, lib, modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../modules/dev.nix
    ../modules/fonts.nix
    ../modules/neovim.nix
    ../modules/nix.nix
    ../modules/rust.nix
    ../modules/nixos/audio.nix
    ../modules/nixos/auth.nix
    ../modules/nixos/bluetooth.nix
    ../modules/nixos/calendar.nix
    ../modules/nixos/email.nix
    ../modules/nixos/firefox.nix
    ../modules/nixos/gnome.nix
    ../modules/nixos/hyprland.nix
    ../modules/nixos/kernel.nix
    ../modules/nixos/locale.nix
    ../modules/nixos/obsidian.nix
    ../modules/nixos/office.nix
    ../modules/nixos/printing.nix
    ../modules/nixos/terminal.nix
    ../modules/nixos/web.nix
    inputs.asahi.nixosModules.apple-silicon-support
  ];

  # Boot configuration.
  # This was auto-generated and should not be changed manually.
  boot = {
    extraModulePackages = [];

    initrd = {
      availableKernelModules = [ "sdhci_pci" "usb_storage" ];
      kernelModules = [ "dm-snapshot" ];
    };

    kernelModules = [];

    # Macbook notch.
    kernelParams = [
      "apple_dcp.show_notch=1"
      "cpuidle.off=1"
      "macsmc_power.log_power=1"
    ];

    loader = {
      efi.canTouchEfiVariables = false;
      systemd-boot.enable = true;
    };
  };

  # File system configuration.
  # This was auto-generated and should not be changed manually.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/cb0e994a-7bd3-4e80-b076-3090232ec8d0";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/3D20-08F6";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  hardware = {
    asahi = {
      experimentalGPUInstallMode = "replace";
      peripheralFirmwareDirectory = ../firmware/asahi;
      setupAsahiSound = true;
      useExperimentalGPUDriver = true;
      withRust = true;
    };

    graphics.enable = true;
  };

  # Enable DHCP on all Ethernet and wireless interfaces.
  networking = {
    hostName = "ceres";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # This was auto-generated and should not be changed manually.
  swapDevices = [];

  system.stateVersion = "25.05";

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
