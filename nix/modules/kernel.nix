{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bc
    bison
    dtc
    flex
    gcc
    gnumake

    # TUI library for menuconfig.
    ncurses5.dev

    # Enables the kernel tools to find libraries.
    pkg-config
  ];
}
