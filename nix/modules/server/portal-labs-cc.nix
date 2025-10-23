{ inputs, modulesName, ... }:
{
  imports = [
    inputs.portal-labs-cc.${modulesName}.default
  ];

  services."portal-labs.cc" = {
    enable = true;
    user = "www-portal";
  };
}
