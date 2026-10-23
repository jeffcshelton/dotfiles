let
  keys = import ./keys;
in
{
  ####################
  # SSH Private Keys #
  ####################

  "keys/apollo/admin.pem.age".publicKeys = with keys; [
    apollo.admin
    apollo.system
    ceres.jeff
    ceres.system
    jupiter.jeff
    jupiter.system
    mercury.jeff
    mercury.system
  ];

  "keys/apollo/system.pem.age".publicKeys = with keys; [
    apollo.admin
    apollo.system
    ceres.jeff
    ceres.system
    jupiter.jeff
    jupiter.system
    mercury.jeff
    mercury.system
  ];

  "keys/mars/admin.pem.age".publicKeys = with keys; [
    ceres.jeff
    ceres.system
    jupiter.jeff
    jupiter.system
    mars.admin
    mars.system
    mercury.jeff
    mercury.system
  ];

  "keys/mars/system.pem.age".publicKeys = with keys; [
    ceres.jeff
    ceres.system
    jupiter.jeff
    jupiter.system
    mars.admin
    mars.system
    mercury.jeff
    mercury.system
  ];

  "keys/venus/admin.pem.age".publicKeys = with keys; [
    ceres.jeff
    ceres.system
    jupiter.jeff
    jupiter.system
    venus.admin
    venus.system
    mercury.jeff
    mercury.system
  ];

  "keys/venus/system.pem.age".publicKeys = with keys; [
    ceres.jeff
    ceres.system
    jupiter.jeff
    jupiter.system
    mercury.jeff
    mercury.system
    venus.admin
    venus.system
  ];

  ##########################
  # Syncthing Private Keys #
  ##########################

  "syncthing/ceres/key.pem.age".publicKeys = with keys; [
    ceres.jeff
    ceres.system
  ];

  "syncthing/mercury/key.pem.age".publicKeys = with keys; [
    mercury.jeff
    mercury.system
  ];

  "syncthing/jupiter/key.pem.age".publicKeys = with keys; [
    jupiter.jeff
    jupiter.system
  ];

  ##########################
  # Cloudflare Tunnel Keys #
  ##########################

  # Personal keys are included so the credentials can be edited and rekeyed
  # from a workstation.
  "tunnels/06684310-6ec1-40a5-ab96-3f31cfe4d185.json.age".publicKeys = with keys; [
    apollo.system
    ceres.jeff
    jupiter.jeff
    mercury.jeff
  ];

  # API token scoped to DNS edits on shelton.one, used to keep the VPN
  # endpoint's record pointed at the current home IP.
  "cloudflare/dns-token.age".publicKeys = with keys; [
    apollo.system
    ceres.jeff
    jupiter.jeff
    mercury.jeff
  ];

  #############################
  # Binary Cache Signing Keys #
  #############################

  # Apollo signs everything it serves; every other machine signs its own
  # builds so Apollo accepts them as uploads.
  "cache/apollo.key.age".publicKeys = with keys; [
    apollo.system
    ceres.jeff
    jupiter.jeff
    mercury.jeff
  ];

  "cache/ceres.key.age".publicKeys = with keys; [
    ceres.jeff
    ceres.system
    jupiter.jeff
    mercury.jeff
  ];

  "cache/jupiter.key.age".publicKeys = with keys; [
    ceres.jeff
    jupiter.jeff
    jupiter.system
    mercury.jeff
  ];

  "cache/mars.key.age".publicKeys = with keys; [
    ceres.jeff
    jupiter.jeff
    mars.system
    mercury.jeff
  ];

  "cache/mercury.key.age".publicKeys = with keys; [
    ceres.jeff
    jupiter.jeff
    mercury.jeff
    mercury.system
  ];

  "cache/venus.key.age".publicKeys = with keys; [
    ceres.jeff
    jupiter.jeff
    mercury.jeff
    venus.system
  ];

  ##########################
  # WireGuard Private Keys #
  ##########################

  "wireguard/apollo.key.age".publicKeys = with keys; [
    apollo.system
    ceres.jeff
    jupiter.jeff
    mercury.jeff
  ];

  "wireguard/ceres.key.age".publicKeys = with keys; [
    ceres.jeff
    ceres.system
    jupiter.jeff
    mercury.jeff
  ];

  "wireguard/jupiter.key.age".publicKeys = with keys; [
    ceres.jeff
    jupiter.jeff
    jupiter.system
    mercury.jeff
  ];

  "wireguard/mars.key.age".publicKeys = with keys; [
    ceres.jeff
    jupiter.jeff
    mars.system
    mercury.jeff
  ];

  "wireguard/mercury.key.age".publicKeys = with keys; [
    ceres.jeff
    jupiter.jeff
    mercury.jeff
    mercury.system
  ];

  "wireguard/venus.key.age".publicKeys = with keys; [
    ceres.jeff
    jupiter.jeff
    mercury.jeff
    venus.system
  ];
}
