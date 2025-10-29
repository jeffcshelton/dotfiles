{ config, host, ... }:
let
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
        "mercury".id = builtins.readFile ../../secrets/syncthing/mercury/device-id.txt;
      };

      folders = {
        "Documents" = {
          path = "${config.home.homeDirectory}/Documents";
          devices = [ "mercury" ];
          id = "documents";
        };

        "Pictures" = {
          path = "${config.home.homeDirectory}/Pictures";
          devices = [ "mercury" ];
          id = "pictures";
        };

        "Videos" = {
          path = "${config.home.homeDirectory}/Videos";
          devices = [ "mercury" ];
          id = "videos";
        };
      };
    };
  };
}
