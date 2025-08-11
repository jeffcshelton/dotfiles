{ pkgs, ... }:
let
  keys = import ../../../keys;
in
{
  systemd.tmpfiles.rules = [
    "d /srv/git 0775 git git -"
  ];

  users = {
    groups.git = {};

    users.git = {
      description = "Git user for hosting repositories.";
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
