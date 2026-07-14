{ inputs, lib, modulesName, pkgs, ... }:
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

  # Permit the deployment administrator to import locally built closures over
  # SSH, such as those sent by nixos-rebuild --target-host.
  nix.settings.trusted-users = lib.mkAfter [ "admin" ];
}
