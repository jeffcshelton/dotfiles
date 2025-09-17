{ ... }:
{
  services.openssh = {
    enable = true;

    # Disable password authentication for greater security.
    settings.PasswordAuthentication = false;
  };
}
