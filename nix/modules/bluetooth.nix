{ isLinux, lib, ... }:
lib.optionalAttrs isLinux {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
}
