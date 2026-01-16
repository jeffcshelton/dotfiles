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

    # Enable mDNS local network hostname discovery.
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;

      publish = {
        enable = true;
        addresses = true;
      };
    };
  })
]
