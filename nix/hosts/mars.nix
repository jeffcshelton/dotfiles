{ pkgs, ... }:
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
  ];

  boot = {
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

  # The original Nix version installed on Mars.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "25.05";
}
