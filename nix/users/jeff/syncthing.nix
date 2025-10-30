{ config, host, lib, ... }:
let
  readID = (host:
    lib.removeSuffix
      "\n"
      (builtins.readFile ../../secrets/syncthing/${host}/device-id.txt)
  );

  configDir = "${config.xdg.configHome}/syncthing";
in
{
  age.secrets."syncthing-key" = {
    file = ../../secrets/syncthing/${host}/key.pem.age;
    path = "${configDir}/key.pem";
  };

  home.file."${configDir}/cert.pem" = {
    source = ../../secrets/syncthing/${host}/cert.pem;
  };

  services.syncthing = {
    enable = true;

    key = config.age.secrets."syncthing-key".path;
    cert = "${configDir}/cert.pem";

    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices = {
        "jupiter".id = readID "jupiter";
        "mercury".id = readID "mercury";
      };

      folders = {
        "Documents" = {
          path = "${config.home.homeDirectory}/Documents";
          devices = [ "jupiter" "mercury" ];
          id = "documents";
        };

        "Pictures" = {
          path = "${config.home.homeDirectory}/Pictures";
          devices = [ "jupiter" "mercury" ];
          id = "pictures";
        };

        "Videos" = {
          path = "${config.home.homeDirectory}/Videos";
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
  };
}
