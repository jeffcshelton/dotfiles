{ ... }:
{
  services.openssh = {
    enable = true;

    # Disable password authentication for greater security.
    settings.PasswordAuthentication = false;
  };

  users.users.jeff.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPUoQxIVJB/B+VzQ3eHBRYoSFZ2y+pfXbpI1UhYWscN1 jupiter"
  ];
}
