# RDP server for the running Hyprland session, configured from
# ~/.config/hypr-rdp/config.toml.
#
# Clients sign in with the desktop user's Linux password through PAM. PAM mode
# requires TLS security without NLA (FreeRDP: `/sec:tls`).

{ inputs, pkgs, ... }:
let
  hypr-rdp = inputs.hypr-rdp.packages.${pkgs.stdenv.hostPlatform.system}.hypr-rdp;
in
{
  environment.systemPackages = [ hypr-rdp ];

  # Only authentication and account checks are used; hypr-rdp attaches to the
  # existing desktop rather than opening a new login session.
  security.pam.services.hypr-rdp = { };

  # Allow RDP connections from the network.
  networking.firewall.allowedTCPPorts = [ 3389 ];

  # Started by Hyprland at login (see hyprland.lua), once the compositor has
  # exported WAYLAND_DISPLAY and HYPRLAND_INSTANCE_SIGNATURE to systemd.
  systemd.user.services.hypr-rdp = {
    description = "RDP server for Hyprland";

    serviceConfig = {
      ExecStart = "${hypr-rdp}/bin/hypr-rdp";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
