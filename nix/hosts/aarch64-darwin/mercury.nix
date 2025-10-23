{ inputs, ... }:
{
  imports = [
    # Bundle
    ../../bundles/full.nix

    # Users
    ../../users/jeff.nix

    inputs.agenix.darwinModules.default
  ];

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
