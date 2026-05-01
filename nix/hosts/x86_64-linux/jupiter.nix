{ config, inputs, pkgs, ... }:
{
  imports = [
    # Bundle
    ../../bundles/full.nix

    # Modules
    ../../modules/kernel.nix
    ../../modules/windows

    # Users
    ../../users/jeff.nix

    # External
    inputs.agenix.nixosModules.default
  ];

  # Windows VM tuning for Jupiter (AMD Ryzen 9).
  # Run `lscpu --extended` to verify core topology before adjusting these.
  windows = {
    vcpus = 4;
    memoryMiB = 8192;
    # Dedicate physical cores 8–11 to the VM; adjust after verifying topology.
    vcpuPinning = [ "8" "9" "10" "11" ];
    user = "Jeff";

    iso = {
      uuid   = "8a51f699-d207-44d6-a4bb-eb07d0276e00";
      sha256 = "sha256-OXG1pzKfKobqDj1AW1RoxsFKeCuAKxed6GPMFtQjw6A=";
    };
  };

  boot = {
    extraModprobeConfig = ''
      options mt7921e disable_aspm=1
    '';

    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "sd_mod"
        "usb_storage"
        "usbhid"
        "xhci_pci"
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

    # 1G hugepages for the Windows VM (10 GiB reserved: 8 GiB VM + overhead).
    # CPU isolation keeps VM vCPUs off the host scheduler for lower latency.
    # Adjust core numbers after running `lscpu --extended` on Jupiter.
    kernelParams = [
      "default_hugepagesz=1G"
      "hugepagesz=1G"
      "hugepages=10"
      "isolcpus=8,9,10,11"
      "nohz_full=8,9,10,11"
      "rcu_nocbs=8,9,10,11"
    ];

    # Substitute the LTS kernel with the newest release.
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    nvidia-vaapi-driver
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
    firmware = [ pkgs.linux-firmware ];

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Enables I2C control for controlling external display brightness.
    i2c.enable = true;

    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };

  # Home manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # Instructs services to use AMD GPU drivers for rendering.
  services.xserver.videoDrivers = [ "nvidia" ];

  swapDevices = [
    { device = "/dev/disk/by-uuid/203490f0-236f-496c-a686-1991051a8556"; }
  ];

  # The original Nix version installed on Jupiter.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "24.11";
}
