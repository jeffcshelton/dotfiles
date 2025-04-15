# Packages and configuration related to enabling system debugging.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    usbutils
  ];
}
