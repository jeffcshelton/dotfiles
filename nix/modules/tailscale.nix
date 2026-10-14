# Tailscale mesh VPN for reaching personal machines from anywhere.
#
# Only tailnet addresses are routed through Tailscale. No exit node or subnet
# routes are configured, so all other traffic leaves through the local network.

{ isDarwin, isLinux, lib, ... }:
lib.mkMerge [
  (lib.optionalAttrs isDarwin {
    # The app, unlike nix-darwin's standalone daemon, configures the MagicDNS
    # search domain so bare hostnames resolve.
    homebrew.casks = [ "tailscale-app" ];
  })

  (lib.optionalAttrs isLinux {
    services.tailscale.enable = true;

    # MagicDNS integrates with systemd-resolved to add the tailnet search domain
    # without taking over all DNS resolution.
    services.resolved.enable = true;
  })
]
