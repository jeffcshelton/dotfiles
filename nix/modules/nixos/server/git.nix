{ pkgs, ... }:
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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPUoQxIVJB/B+VzQ3eHBRYoSFZ2y+pfXbpI1UhYWscN1 jupiter"
      ];
    };
  };
}
