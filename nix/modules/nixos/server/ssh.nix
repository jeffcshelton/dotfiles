{ ... }:
let
  keys = import ../../../keys;
in
{
  services.openssh = {
    enable = true;

    # Disable password authentication for greater security.
    settings.PasswordAuthentication = false;
  };

  users.users.jeff.openssh.authorizedKeys.keys = [
    keys.ceres.jeff
    keys.jupiter.jeff
    keys.mercury.jeff
  ];
}
