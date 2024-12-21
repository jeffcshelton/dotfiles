{ ... }:
{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  users.users.jeff = {
    home = "/home/jeff";
    isNormalUser = true;
  };
}
