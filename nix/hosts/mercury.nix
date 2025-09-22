{ ... }:
{
  imports = [
    # General modules
    ../modules/fonts.nix
    ../modules/dev.nix
    ../modules/ml.nix
    ../modules/neovim.nix
    ../modules/nix.nix
    ../modules/rust.nix
    ../modules/shell.nix
    ../modules/ssh.nix
    ../modules/typesetting.nix

    # macOS modules
    ../modules/macos/apps.nix
    ../modules/macos/containers.nix
    ../modules/macos/controlcenter.nix
    ../modules/macos/dock.nix
    ../modules/macos/finder.nix
    ../modules/macos/homebrew.nix
    ../modules/macos/minecraft.nix
    ../modules/macos/office.nix
    ../modules/macos/printing.nix
    ../modules/macos/terminal.nix

    # Users
    ../users/jeff.nix
  ];

  # Enable Homebrew support.
  # Other modules rely on this to be enabled.
  homebrew.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nix.linux-builder = {
    enable = true;
    maxJobs = 4;
  };

  system = {
    primaryUser = "jeff";
    stateVersion = 5;
  };
}
