{ lib, pkgs, ... }:
let
  keys = import ../../../keys;
in
{
  services.openssh = lib.mkDefault {
    enable = true;
  };

  systemd.tmpfiles.rules = [
    "d /srv/git 0775 git git -"
  ];

  users = {
    groups.git = {};

    users.git = {
      description = "Git user for hosting repositories.";
      home = "/srv/git";
      group = "git";
      isSystemUser = true;
      shell = "${pkgs.git}/bin/git-shell";

      openssh.authorizedKeys.keys = [
        keys.ceres.jeff
        keys.jupiter.jeff
        keys.mercury.jeff
      ];
    };
  };
}
