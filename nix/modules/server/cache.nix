# Binary cache shared over the VPN at cache.shelton.one, serving everything in
# this host's store.
#
# Paths are signed as they are served. Every other machine uploads its local
# builds here through modules/cache.nix, so a path built on one machine is
# available to all of them.

{ config, inputs, lib, modulesName, ... }:
let
  keys = import ../../secrets/keys;

  # Every machine with a cache signing key, other than this one, uploads.
  uploaders = lib.remove "apollo" (map (lib.removeSuffix ".pub")
    (builtins.filter (lib.hasSuffix ".pub")
      (builtins.attrNames (builtins.readDir ../../secrets/cache))));
in
{
  imports = [
    ../nix.nix
    ../wireguard.nix
    inputs.agenix.${modulesName}.default
  ];

  age.secrets.cache-signing-key.file = ../../secrets/cache/apollo.key.age;

  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ config.age.secrets.cache-signing-key.path ];

    # Systemd opens the socket, so harmonia itself needs no privileges for
    # port 80. The default priority of 50 ranks below cache.nixos.org, so
    # clients only fetch what public caches lack.
    settings.bind = "[::]:80";
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 80 ];

  # Uploads arrive over SSH as an unprivileged user restricted to the Nix
  # daemon protocol. The daemon only lets it add paths signed by a trusted key.
  users = {
    groups.nix-upload = { };

    users.nix-upload = {
      description = "Binary cache uploads";
      group = "nix-upload";
      isSystemUser = true;
      useDefaultShell = true;

      openssh.authorizedKeys.keys = map
        (host: ''command="${config.nix.package}/bin/nix-daemon --stdio",restrict ${keys.${host}.system}'')
        uploaders;
    };
  };

  nix = {
    # Uploaded paths have no GC roots, so scheduled collection would empty the
    # cache. Collect only when the disk runs low instead.
    gc.automatic = lib.mkForce false;

    settings = {
      min-free = 20 * 1024 * 1024 * 1024;
      max-free = 60 * 1024 * 1024 * 1024;

      extra-trusted-public-keys = map
        (host: lib.removeSuffix "\n"
          (builtins.readFile ../../secrets/cache/${host}.pub))
        uploaders;
    };
  };
}
