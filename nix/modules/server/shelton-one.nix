{ inputs, ... }:
{
  imports = [
    inputs.shelton-one.nixosModules.default
  ];

  services."shelton.one" = {
    enable = true;
    user = "www-shelton";
  };
}
