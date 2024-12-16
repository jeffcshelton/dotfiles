{
  description = "Jeff's Personal Flake";

  inputs = {
    darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin";
    };

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, darwin, flake-utils, home-manager, nixpkgs }: {
    darwinConfigurations.mercury = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/mercury.nix
        ./system/common.nix
        ./system/macos.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.users.jeff = import ./users/jeff.nix;
        }
      ];
    };

    nixosConfigurations.jupiter = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/jupiter.nix
        ./system/common.nix
        ./system/nixos.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.jeff = import ./users/jeff.nix;
          };
        }
      ];
    };
  };
}
