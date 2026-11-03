# The shelton.one DNS zone on Cloudflare, declared in Nix.
#
# Modules add the records for what they serve to `server.dns.records`, and
# every Cloudflare tunnel hostname gets its CNAME automatically. On boot and
# whenever the records change, dnscontrol makes the zone match exactly:
# anything not declared is deleted. Names kept current by cloudflare-dyndns
# (vpn.shelton.one) are left to it.
#
# Preview what a deploy would change, from this directory:
#
#   nix build .#nixosConfigurations.apollo.config.system.build.dnsconfig
#   CLOUDFLARE_API_TOKEN=... dnscontrol preview --config result \
#     --creds <(echo '{"cloudflare": {"TYPE": "CLOUDFLAREAPI", "apitoken": "$CLOUDFLARE_API_TOKEN"}}')

{ config, inputs, lib, modulesName, pkgs, ... }:
let
  cfg = config.server.dns;
  inherit (cfg) zone;

  record = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Full name, e.g. git.shelton.one, or the zone itself.";
      };

      type = lib.mkOption {
        type = lib.types.enum [ "A" "AAAA" "CNAME" "MX" "TXT" ];
      };

      content = lib.mkOption {
        type = lib.types.str;
        description = "Address, target host name (no trailing dot), or text.";
      };

      priority = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "MX priority.";
      };

      proxied = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Serve through Cloudflare's proxy, hiding the origin.";
      };
    };
  };

  # dnscontrol names records relative to the zone, with "@" for the zone.
  label = name:
    if name == zone then "@"
    else if lib.hasSuffix ".${zone}" name then lib.removeSuffix ".${zone}" name
    else throw "DNS record ${name} is outside ${zone}";

  toJs = r:
    let
      name = builtins.toJSON (label r.name);
      proxy = lib.optionalString r.proxied ", CF_PROXY_ON";
      host = builtins.toJSON "${r.content}.";
    in
    if r.type == "MX" then "MX(${name}, ${toString r.priority}, ${host})"
    # Cloudflare flattens a CNAME at the zone apex, which dnscontrol calls ALIAS.
    else if r.type == "CNAME" then "${if name == ''"@"'' then "ALIAS" else "CNAME"}(${name}, ${host}${proxy})"
    else "${r.type}(${name}, ${builtins.toJSON r.content}${proxy})";

  # Names whose address follows the home IP; cloudflare-dyndns updates them.
  dynamic = lib.optionals config.services.cloudflare-dyndns.enable
    config.services.cloudflare-dyndns.domains;

  dnsconfig = pkgs.writeText "dnsconfig.js" ''
    D(${builtins.toJSON zone}, NewRegistrar("none"), DnsProvider(NewDnsProvider("cloudflare")),
      // Cloudflare's "automatic" TTL.
      DefaultTTL(1),
    ${lib.concatMapStrings (name: "  IGNORE(${builtins.toJSON (label name)}, \"A,AAAA\"),\n") dynamic}${
      lib.concatMapStringsSep ",\n" (r: "  " + toJs r) cfg.records}
    );
  '';

  # dnscontrol reads the token from the environment, never from this file.
  creds = pkgs.writeText "creds.json" (builtins.toJSON {
    cloudflare = {
      TYPE = "CLOUDFLAREAPI";
      apitoken = "$CLOUDFLARE_API_TOKEN";
    };
  });
in
{
  imports = [
    inputs.agenix.${modulesName}.default
  ];

  options.server.dns = {
    enable = lib.mkEnableOption "keeping the Cloudflare DNS zone in sync";

    zone = lib.mkOption {
      type = lib.types.str;
      default = "shelton.one";
    };

    records = lib.mkOption {
      type = lib.types.listOf record;
      default = [ ];
      description = "Every record in the zone. Undeclared records are deleted.";
    };
  };

  config = {
    server.dns.records =
      # Hostnames served through a Cloudflare tunnel, public by design.
      lib.concatLists (lib.mapAttrsToList
        (id: tunnel: map
          (name: {
            inherit name;
            type = "CNAME";
            content = "${id}.cfargotunnel.com";
            proxied = true;
          })
          (builtins.attrNames tunnel.ingress))
        config.services.cloudflared.tunnels)

      # iCloud Mail for addresses at shelton.one.
      ++ [
        { name = zone; type = "MX"; priority = 10; content = "mx01.mail.icloud.com"; }
        { name = zone; type = "MX"; priority = 10; content = "mx02.mail.icloud.com"; }
        { name = zone; type = "TXT"; content = "v=spf1 include:icloud.com ~all"; }
        { name = zone; type = "TXT"; content = "apple-domain=IQHRUrZcvj5TSVxC"; }
        { name = "sig1._domainkey.${zone}"; type = "CNAME"; content = "sig1.dkim.${zone}.at.icloudmailadmin.com"; }
      ];

    # Built so the zone can be previewed before a deploy.
    system.build.dnsconfig = dnsconfig;

    age.secrets.cloudflare-dns-token = lib.mkIf cfg.enable {
      file = ../../secrets/cloudflare/dns-token.age;
    };

    systemd.services.cloudflare-dns = lib.mkIf cfg.enable {
      description = "Make the ${zone} DNS zone match its declared records";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      # Push again whenever the declared records change.
      restartTriggers = [ dnsconfig ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        DynamicUser = true;
        LoadCredential = "token:${config.age.secrets.cloudflare-dns-token.path}";

        # Retry if the network or Cloudflare is briefly unavailable.
        Restart = "on-failure";
        RestartSec = 60;
      };

      script = ''
        CLOUDFLARE_API_TOKEN=$(< "$CREDENTIALS_DIRECTORY/token")
        export CLOUDFLARE_API_TOKEN
        exec ${lib.getExe pkgs.dnscontrol} push --config ${dnsconfig} --creds ${creds}
      '';
    };
  };
}
