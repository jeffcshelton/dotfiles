{ pkgs, ... }:
{
  imports = [
    ../modules/fonts.nix
    ../modules/macos/apps.nix
    ../modules/macos/controlcenter.nix
    ../modules/macos/dock.nix
    ../modules/macos/finder.nix
    ../modules/macos/homebrew.nix
    ../modules/macos/minecraft.nix
    ../modules/macos/office.nix
    ../modules/macos/postgres.nix
    ../modules/macos/printing.nix
    ../modules/macos/terminal.nix
    ../modules/neovim.nix
    ../modules/nix.nix
    ../modules/tools.nix
  ];

  # Enable Homebrew support.
  # Other modules rely on this to be enabled.
  homebrew.enable = true;

  system.stateVersion = 5;

  users.users.jeff = {
    name = "jeff";
    home = "/Users/jeff";
  };
}
