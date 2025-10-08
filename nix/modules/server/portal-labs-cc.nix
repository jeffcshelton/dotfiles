{ inputs, ... }:
{
  imports = [
    inputs.portal-labs-cc.nixosModules.default
  ];

  services."portal-labs.cc" = {
    enable = true;
    user = "www-portal";
  };
}
