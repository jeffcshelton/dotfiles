{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.postgresql ];

  services.postgresql = {
    authentication = ''
      # Allow all loopback TCP/IP connections (IPv4 and IPv6) without requiring
      # a password.

      # TYPE   DATABASE   USER   ADDRESS       METHOD
      host     all        all    127.0.0.1/8   trust
      host     all        all    ::1/128       trust
    '';

    enable = true;
    enableTCPIP = true;
  };
}
