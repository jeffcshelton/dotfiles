# Packages and configuration related to enabling system debugging.

{ isLinux, lib, pkgs, ... }:
lib.optionalAttrs isLinux {
  environment.systemPackages = with pkgs; [
    usbutils
  ];
}
