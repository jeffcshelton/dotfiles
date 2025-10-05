{ ... }:
{
  services.openssh = {
    enable = true;
    extraConfig = ''
      ChallengeResponseAuthentication no
      PasswordAuthentication no
      UsePAM no
    '';
  };
}
