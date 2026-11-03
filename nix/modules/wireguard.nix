# Self-hosted WireGuard network for reaching personal machines from anywhere.
#
# Apollo is the hub: every other peer keeps a tunnel to it at vpn.shelton.one,
# and it forwards traffic between peers. Only the VPN subnet is routed through
# the tunnel, so all other traffic leaves through the local network.
#
# Each peer that accepts SSH is reachable by its bare hostname, e.g.
# `ssh apollo`.

{ config, host, inputs, isDarwin, isLinux, lib, modulesName, ... }:
let
  hub = "apollo";
  endpoint = "vpn.shelton.one";
  port = 51820;
  subnet = "10.100.0.0/24";

  # Every machine on the VPN, its tunnel address, the user to SSH in as when it
  # differs from the local username, and whether it runs an SSH server at all.
  peers = {
    apollo = { address = "10.100.0.1"; };
    jupiter = { address = "10.100.0.2"; };
    mercury = { address = "10.100.0.3"; };
    ceres = { address = "10.100.0.4"; };
    mars = { address = "10.100.0.5"; user = "admin"; };
    venus = { address = "10.100.0.6"; user = "admin"; };
    neptune = { address = "10.100.0.7"; ssh = false; };
  };

  # Peers that accept SSH. Others, such as phones, only join the tunnel.
  sshPeers = lib.filterAttrs (_name: peer: peer.ssh or true) peers;

  publicKey = name: lib.removeSuffix "\n"
    (builtins.readFile ../secrets/wireguard/${name}.pub);

  address = peers.${host}.address;
  privateKeyFile = config.age.secrets.wireguard.path;

  hubPeer = {
    publicKey = publicKey hub;
    allowedIPs = [ subnet ];
    endpoint = "${endpoint}:${toString port}";

    # Keep the NAT mapping open so the hub can always reach roaming peers.
    persistentKeepalive = 25;
  };
in
{
  imports = [
    ./ssh.nix
    inputs.agenix.${modulesName}.default
  ];

  # Lets other modules point at this machine over the VPN, e.g. in private DNS
  # records (modules/server/dns.nix).
  options.vpn.address = lib.mkOption {
    type = lib.types.str;
    readOnly = true;
    default = address;
    description = "This machine's address on the VPN.";
  };

  config = lib.mkMerge [
    {
      age.secrets.wireguard.file = ../secrets/wireguard/${host}.key.age;

      # Known host keys also match VPN addresses, which is what SSH checks
      # after resolving the aliases below.
      programs.ssh.knownHosts = lib.mapAttrs
        (_name: peer: { extraHostNames = [ peer.address ]; })
        sshPeers;

      programs.ssh.extraConfig = lib.concatStrings (lib.mapAttrsToList
        (name: peer: ''
          Host ${name}
            HostName ${peer.address}
        '' + lib.optionalString (peer ? user) "  User ${peer.user}\n")
        sshPeers) + ''

        # Git over SSH to git@shelton.one reaches the hub's Gitea SSH server
        # (modules/server/gitea.nix), since Cloudflare only proxies its HTTP.
        Match host shelton.one user git
          HostName ${peers.${hub}.address}
          Port 2223
      '';
    }

    (lib.optionalAttrs (isLinux && host == hub) {
      networking.wireguard.interfaces.wg0 = {
        inherit privateKeyFile;
        ips = [ "${address}/24" ];
        listenPort = port;

        peers = lib.mapAttrsToList
          (name: peer: {
            publicKey = publicKey name;
            allowedIPs = [ "${peer.address}/32" ];
          })
          (removeAttrs peers [ hub ]);
      };

      # Peers only reach each other through the hub.
      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

      # The router forwards this port from the home IP to the hub.
      networking.firewall.allowedUDPPorts = [ port ];

      # The home IP is not static, so keep the endpoint record current. It
      # must not be proxied, as Cloudflare's proxy cannot carry WireGuard.
      age.secrets.cloudflare-dns-token.file = ../secrets/cloudflare/dns-token.age;

      services.cloudflare-dyndns = {
        enable = true;
        apiTokenFile = config.age.secrets.cloudflare-dns-token.path;
        domains = [ endpoint ];
        proxied = false;
      };
    })

    (lib.optionalAttrs (isLinux && host != hub) {
      networking.wireguard.interfaces.wg0 = {
        inherit privateKeyFile;
        ips = [ "${address}/32" ];

        # Re-resolve the endpoint so the tunnel follows home IP changes.
        peers = [ (hubPeer // { dynamicEndpointRefreshSeconds = 300; }) ];
      };
    })

    (lib.optionalAttrs isDarwin {
      networking.wg-quick.interfaces.wg0 = {
        inherit privateKeyFile;
        address = [ "${address}/32" ];
        peers = [ hubPeer ];
      };
    })
  ];
}
