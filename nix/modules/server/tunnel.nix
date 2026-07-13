{ config, inputs, lib, modulesName, ... }:
let
  cfg = config.server.cloudflare;

  secrets = lib.mapAttrs' (key: value:
    {
      name = "tunnel-${key}";
      value = {
        file = ../../secrets/tunnels/${key}.json.age;
        owner = "cloudflared";
        group = "cloudflared";
        mode = "0400";
      };
    }
  ) cfg.tunnels;

  # Apply options from the host file.
  tunnels = lib.mapAttrs (key: value:
    {
      credentialsFile = config.age.secrets."tunnel-${key}".path;
      default = "http_status:404";
    } // value
  ) cfg.tunnels;
in
{
  options.server.cloudflare = {
    enable = lib.mkEnableOption "Cloudflare tunnels";

    tunnels = lib.mkOption {
      default = { };
      description = "Cloudflare tunnels and their ingress configuration.";
      type = lib.types.attrsOf (lib.types.attrs);
    };
  };

  imports = [
    inputs.agenix.${modulesName}.default
  ];

  config = lib.mkIf cfg.enable {
    age = { inherit secrets; };
    services.cloudflared = {
      inherit tunnels;
      enable = true;
    };
  };
}
