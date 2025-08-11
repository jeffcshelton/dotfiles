{ config, lib, ... }:
let
  secrets = lib.mapAttrs' (key: value:
    {
      name = "cloudflare-${key}";
      value = {
        file = ../../../secrets/cloudflare-${key}.json.age;
      };
    }
  ) config.server.tunnels;

  # Apply options from the host file.
  tunnels = lib.mapAttrs (key: value:
    {
      credentialsFile = config.age.secrets."cloudflare-${key}".path;
      default = "http_status:404";
    } // value
  ) config.server.tunnels;
in
{
  config = {
    age.secrets = secrets;

    services.cloudflared = {
      enable = true;
      tunnels = tunnels;
    };
  };

  # Define options for the host file to set to specify the tunnel.
  options.server.tunnels = lib.mkOption {
    default = {};
    description = "Server Cloudflare tunnels configuration.";
    type = lib.types.attrsOf (lib.types.attrs);
  };
}
