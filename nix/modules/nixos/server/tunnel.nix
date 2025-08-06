{ config, lib, ... }:
let
  tunnel = config.services.cloudflared.tunnel;
in
{
  services.cloudflared = {
    enable = true;

    tunnels.${tunnel.uuid} = {
      credentialFile = "/run/cloudflared/${tunnel.uuid}.json";
      default = "http_status:404";

      extraFiles = {
        "/run/cloudflared/${tunnel.uuid}.json" = {
          source = ./secrets/${tunnel.uuid}.json;
          mode = "0400";
        };
      };
    } // (lib.removeAttrs tunnel [ "uuid" ]);
  };
}
