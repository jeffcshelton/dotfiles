{ inputs, lib, modulesPath, pkgs, ... }:
{
  imports = [
    # General modules
    ../../modules/dev.nix
    ../../modules/fonts.nix
    ../../modules/neovim.nix
    ../../modules/nix.nix
    ../../modules/rust.nix
    ../../modules/shell.nix
    ../../modules/ssh.nix

    # NixOS modules
    ../../modules/audio.nix
    ../../modules/auth.nix
    ../../modules/bluetooth.nix
    ../../modules/calendar.nix
    ../../modules/firefox.nix
    ../../modules/gnome.nix
    ../../modules/hyprland.nix
    ../../modules/kernel.nix
    ../../modules/locale.nix
    ../../modules/obsidian.nix
    ../../modules/office.nix
    ../../modules/printing.nix
    ../../modules/terminal.nix
    ../../modules/web.nix

    # Server modules
    ../../modules/server/ssh.nix

    # Users
    ../../users/jeff.nix

    # Hardware modules
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.agenix.nixosModules.default
    inputs.asahi.nixosModules.apple-silicon-support
    inputs.home-manager.nixosModules.default
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
      peripheralFirmwareDirectory = ../../firmware/asahi;
      setupAsahiSound = true;
    };

    graphics = {
      enable = true;
      package = lib.mkForce pkgs.mesa;
    };
  };

  # Enable DHCP on all Ethernet and wireless interfaces.
  networking = {
    hostName = "ceres";
    networkmanager.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # This was auto-generated and should not be changed manually.
  swapDevices = [];

  system.stateVersion = "25.05";
}
