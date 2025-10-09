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

  # Provide additional known hostnames for specific hosts.
  extraHostNames = {
    "mars" = [ "mars.shelton.one" ];
  };

  # Merge the system keys list with the extra hostnames list.
  knownHosts = lib.recursiveUpdate
    systemHosts
    (lib.mapAttrs
      (name: hostnames: {
        extraHostNames = hostnames;
      })
      extraHostNames
    );
in
{
  programs.ssh = {
    extraConfig = ''
      Host mars.shelton.one
        ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h
    '';

    knownHosts = knownHosts;
  };
}
