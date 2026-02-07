{ config, home, host, isDarwin, isLinux, lib, ... }:
let
  readID = (host:
    lib.removeSuffix
      "\n"
      (builtins.readFile ../../secrets/syncthing/${host}/device-id.txt)
  );

  configDir = "${home}/.config/syncthing";
  settings = {
    devices = {
      "jupiter".id = readID "jupiter";
      "mercury".id = readID "mercury";
    };

    folders = {
      "Documents" = {
        path = "${home}/Documents";
        devices = [ "jupiter" "mercury" ];
        id = "documents";
      };

      "Pictures" = {
        path = "${home}/Pictures";
        devices = [ "jupiter" "mercury" ];
        id = "pictures";
      };

      "Videos" = {
        path = "${home}/Videos";
        devices = [ "jupiter" "mercury" ];
        id = "videos";
      };
    };

    options = {
      localAnnounceEnabled = true;
      relaysEnabled = true;
      urAccepted = -1;
    };
  };
in
lib.mkMerge [
  # macOS requires using the Syncthing system service, as the home-manager
  # service is not supported.
  (lib.optionalAttrs isDarwin {
    age.secrets."syncthing-key" = {
      file = ../../secrets/syncthing/${host}/key.pem.age;
      owner = "jeff";
    };

    services.syncthing = {
      inherit configDir settings;
      enable = true;
      user = "jeff";
      dataDir = "${home}/.local/share/syncthing";

      key = config.age.secrets."syncthing-key".path;
      cert = ../../secrets/syncthing/${host}/cert.pem;

      overrideDevices = true;
      overrideFolders = true;
    };
  })

  # NixOS can use the home-manager service.
  (lib.optionalAttrs isLinux {
    home-manager.users.jeff = {
      age.secrets."syncthing-key" = {
        file = ../../secrets/syncthing/${host}/key.pem.age;
        path = "${configDir}/key.pem";
      };

      home.file."${configDir}/cert.pem" = {
        source = ../../secrets/syncthing/${host}/cert.pem;
      };

      services.syncthing = {
        inherit settings;
        enable = true;

        key = config.home-manager.users.jeff.age.secrets."syncthing-key".path;
        cert = "${configDir}/cert.pem";

        overrideDevices = true;
        overrideFolders = true;
      };
    };
  })
]
