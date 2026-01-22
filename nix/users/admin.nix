{ inputs, modulesName, pkgs, ... }:
let
  keys = import ../secrets/keys;
in
{
  imports = [
    inputs.home-manager.${modulesName}.default
  ];

  users.users.admin = {
    description = "Server Administrator";
    home = "/home/admin";
    isNormalUser = true;
    shell = pkgs.bash;

    extraGroups = [
      "dialout"
      "gpio"
      "i2c"
      "spi"
      "wheel"
    ];

    openssh.authorizedKeys.keys = with keys; [
      ceres.jeff
      jupiter.jeff
      mercury.jeff
    ];
  };
}
