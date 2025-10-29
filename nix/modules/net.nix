{ host, isLinux, lib, ... }:
lib.mkMerge [
  {
    networking.hostName = host;
  }

  (lib.optionalAttrs isLinux {
    networking.networkmanager.enable = true;
  })
]
