# ATM, the water tank sales tool (git.shelton.one/jeff/atm), with its own
# PostgreSQL + PostGIS database and scheduled ingests of public data. The host
# file publishes its port through the Cloudflare tunnel.
#
# The repository is private, so the flake input is fetched over SSH by
# whoever evaluates this configuration: jeff with his own key, and root
# (`sudo nixos-rebuild`) with this host's key, a read-only deploy key on the
# repository (modules/server/gitea.nix).

{ inputs, modulesName, ... }:
{
  imports = [
    ./gitea.nix
    inputs.atm.${modulesName}.default
  ];

  services.atm.enable = true;
}
