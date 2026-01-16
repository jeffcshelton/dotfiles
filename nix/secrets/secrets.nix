let
  keys = import ./keys;
in
{
  ####################
  # SSH Private Keys #
  ####################

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

  "tunnels/06684310-6ec1-40a5-ab96-3f31cfe4d185.json.age".publicKeys = [
    keys.mars.system
  ];
}
