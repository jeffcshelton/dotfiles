# RGB case lighting support.

{ isLinux, lib, ... }:
lib.optionalAttrs isLinux {
  services.hardware.openrgb.enable = true;
}
