{ pkgs, ... }:
{
  imports = [
    ../modules/ai.nix
    ../modules/dev.nix
    ../modules/fonts.nix
    ../modules/neovim.nix
    ../modules/nix.nix
    ../modules/rust.nix
    ../modules/shell.nix
    ../modules/ssh.nix
    ../modules/typesetting.nix

    ../modules/nixos/audio.nix
    ../modules/nixos/auth.nix
    ../modules/nixos/cad.nix
    ../modules/nixos/conference.nix
    ../modules/nixos/email.nix
    ../modules/nixos/debug.nix
    ../modules/nixos/emulation.nix
    ../modules/nixos/firefox.nix
    ../modules/nixos/fpga.nix
    ../modules/nixos/gnome.nix
    ../modules/nixos/hyprland.nix
    ../modules/nixos/llm.nix
    ../modules/nixos/locale.nix
    ../modules/nixos/minecraft.nix
    ../modules/nixos/music.nix
    ../modules/nixos/obsidian.nix
    ../modules/nixos/office.nix
    ../modules/nixos/photo.nix
    ../modules/nixos/printing.nix
    ../modules/nixos/rgb.nix
    ../modules/nixos/terminal.nix
    ../modules/nixos/video.nix
    ../modules/nixos/virtualization.nix
    ../modules/nixos/vpn.nix
    ../modules/nixos/web.nix
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

      kernelModules = [
        # Support for the AMD graphics card.
        "amdgpu"
      ];

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

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # Diagnostic tools for AMD GPUs.
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
  ];

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

    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        amdvlk
        rocmPackages.clr.icd
      ];

      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };

    # Enables I2C control for controlling external display brightness.
    i2c.enable = true;
  };

  # Home manager versioning.
  home-manager.users.jeff.home.stateVersion = "25.05";

  # Networking configuration.
  networking = {
    hostName = "jupiter";
    networkmanager.enable = true;
  };

  # Instructs services to use AMD GPU drivers for rendering.
  services = {
    ollama = {
      acceleration = "rocm";
      rocmOverrideGfx = "11.0.0";
    };

    xserver.videoDrivers = [ "amdgpu" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/203490f0-236f-496c-a686-1991051a8556"; }
  ];

  # The original Nix version installed on Jupiter.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "24.11";

  # Most software has the HIP libraries hard-coded.
  # This line ensures that programs can find the libraries.
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  users.users.jeff = {
    description = "Jeff Shelton";

    extraGroups = [
      "audio"
      "docker"
      "i2c"
      "input"
      "lp"
      "networkmanager"
      "render"
      "scanner"
      "seat"
      "video"
      "wheel"
    ];

    home = "/home/jeff";
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}
