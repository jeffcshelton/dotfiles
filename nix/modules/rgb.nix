# RGB case lighting support.

{ isLinux, lib, unstable, ... }:
lib.optionalAttrs isLinux {
  services.hardware.openrgb = {
    enable = true;
    package = unstable.openrgb;
  };
}
