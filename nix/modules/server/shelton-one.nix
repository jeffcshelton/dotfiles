{ inputs, modulesName, ... }:
{
  imports = [
    inputs.shelton-one.${modulesName}.default
  ];

  services."shelton.one" = {
    enable = true;
    user = "www-shelton";
  };
}
