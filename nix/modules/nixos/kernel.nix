{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bc
    bison
    flex
    gcc
    gnumake

    # TUI library for menuconfig.
    ncurses5.dev

    # Enables the kernel tools to find libraries.
    pkg-config

    # GCC cross compiler for building arm64 kernels.
    pkgsCross.aarch64-multiplatform.buildPackages.gcc
  ];
}
