{ inputs, ... }:
{
  imports = [
    inputs.website.nixosModules.default
  ];

  # Open port 80 so the website can be accessed externally.
  networking.firewall = {
    allowedTCPPorts = [ 80 ];
    allowedUDPPorts = [ 80 ];
  };

  services."shelton.one".enable = true;
}
