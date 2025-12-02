{ host, isLinux, lib, pkgs, ... }:
lib.mkMerge [
  {
    networking.hostName = host;
  }

  (lib.optionalAttrs isLinux {
    environment.systemPackages = with pkgs; [
      iw
    ];

    networking = {
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };

      wireless.iwd.enable = true;
    };
  })
]
