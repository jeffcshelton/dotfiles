{ self, pkgs, ... }:
{
  imports = [
    ../modules/fonts.nix
    ../modules/macos/apps.nix
    ../modules/macos/finder.nix
    ../modules/macos/nix.nix
    ../modules/macos/system.nix
    ../modules/tools.nix
  ];

  users.users.jeff = {
    name = "jeff";
    home = "/Users/jeff";
  };
}
