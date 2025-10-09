let
  keys = import ./keys;
in
{
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

  "tunnels/23637481-8e77-4e1d-825b-824831e929b1.json.age".publicKeys = [
    keys.mars.system
  ];

  "tunnels/eef93350-83b3-47a9-8dfb-797166548789.json.age".publicKeys = [
    keys.venus.system
  ];
}
