{ pkgs, ... }:
let
  keys = import ../keys;
in
{
  users.users.admin = {
    description = "Server Administrator";
    home = "/home/admin";
    isNormalUser = true;
    shell = pkgs.zsh;

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
