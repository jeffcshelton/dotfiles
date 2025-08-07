{ lib, pkgs, ... }:
{
  imports = [
    ../modules/dev.nix
    ../modules/neovim.nix
    ../modules/nix.nix
    ../modules/rust.nix
    ../modules/ssh.nix

    ../modules/nixos/bluetooth.nix
    ../modules/nixos/debug.nix
    ../modules/nixos/kernel.nix
    ../modules/nixos/locale.nix
    ../modules/nixos/terminal.nix

    ../modules/nixos/server/git.nix
    ../modules/nixos/server/ssh.nix
    ../modules/nixos/server/tunnel.nix
  ];

  boot = {
    growPartition = true;

    kernelModules = [
      "gpio-dev"
      "i2c-dev"
      "spi-dev"
      "spidev"
    ];

    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
  };

  fileSystems = lib.mkDefault {
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

  # Networking configuration.
  networking = {
    hostName = "mars";
    networkmanager.enable = true;
  };

  # An overlay that allows default kernel modules to be excluded if they were
  # not compiled with this kernel version.
  #
  # This is necessary for image generation, as nixpkgs included a standard set
  # of kernel modules when bundling into an image, but some are not included or
  # necessary for the Raspberry Pi 4B (specifically sun4i-drm). This overlay is
  # a temporary workaround until that issue can be fixed.
  #
  # See: https://github.com/NixOS/nixpkgs/issues/154163
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = modules:
        super.makeModulesClosure (modules // { allowMissing = true; });
    })
  ];

  # It's necessary to disable sudo's password requirement for wheel users since
  # the primary user does not have a password.
  #
  # Without this, sudo will still prompt for a password but none will work.
  security.sudo.wheelNeedsPassword = false;

  users.users.jeff = {
    description = "Jeff Shelton";
    home = "/home/jeff";
    isNormalUser = true;
    shell = pkgs.zsh;

    extraGroups = [
      "dialout"
      "gpio"
      "i2c"
      "spi"
      "wheel"
    ];
  };

  # Cloudflare tunnel definition and rules.
  server.tunnels."0d022530-69c4-4af0-9b80-a82c25918361".ingress = {
    "shelton.one" = "http://localhost:80";
    "mars.shelton.one" = "ssh://localhost:22";
  };

  # The original Nix version installed on Mars.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "25.05";

  # Enable compressed RAM swap, as Mars is a low-memory device.
  zramSwap.enable = true;
}
