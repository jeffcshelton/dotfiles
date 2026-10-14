{ lib, ... }:
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
  programs.ssh.knownHosts = systemHosts;
}
