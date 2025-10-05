{ inputs, ... }:
{
  imports = [
    # Bundle
    ../../bundles/full.nix

    # Users
    ../../users/jeff.nix

    inputs.agenix.darwinModules.default
    inputs.home-manager.darwinModules.default
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
