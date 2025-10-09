{ config, inputs, lib, ... }:
let
  secrets = lib.mapAttrs' (key: value:
    {
      name = "tunnel-${key}";
      value = {
        file = ../../secrets/tunnels/${key}.json.age;
      };
    }
  ) config.server.tunnels;

  # Apply options from the host file.
  tunnels = lib.mapAttrs (key: value:
    {
      credentialsFile = config.age.secrets."tunnel-${key}".path;
      default = "http_status:404";
    } // value
  ) config.server.tunnels;
in
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config = {
    age = { inherit secrets; };
    services.cloudflared = {
      inherit tunnels;
      enable = true;
    };
  };

  # Define options for the host file to set to specify the tunnel.
  options.server.tunnels = lib.mkOption {
    default = {};
    description = "Server Cloudflare tunnels configuration.";
    type = lib.types.attrsOf (lib.types.attrs);
  };
}
