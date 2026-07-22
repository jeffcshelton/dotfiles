{ lib, pkgs, ... }:
let
  keys = import ../secrets/keys;

  # Add all hosts with system keys to known hosts.
  systemHosts = lib.mapAttrs
    (name: value: {
      publicKey = value.system;
    })
    (lib.filterAttrs
      (_: value: lib.hasAttr "system" value)
      keys
    );
in
{
  programs.ssh = {
    extraConfig = ''
      Match host shelton.one user git
        HostKeyAlias git-ssh.shelton.one
        ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname git-ssh.shelton.one

      Match all

      Host mars.shelton.one
        ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h
    '';

    knownHosts = systemHosts;
  };
}
