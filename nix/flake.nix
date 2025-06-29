{
  description = "Jeff's Personal Flake";

  inputs = {
    asahi.url = "github:nix-community/nixos-apple-silicon";

    darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin";
    };

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
  };

  outputs = { darwin, home-manager, nixpkgs, ... } @ inputs:
    # Modules that should be included for all machines.
    let modules = [ home-manager.nixosModules.home-manager ];
  in {
    darwinConfigurations = {
      mercury = darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        system = "aarch64-darwin";
        modules = modules ++ [ ./hosts/mercury.nix ];
      };
    };

    nixosConfigurations = {
      ceres = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
	      modules = modules ++ [ ./hosts/ceres.nix ];
      };

      jupiter = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = modules ++ [ ./hosts/jupiter.nix ];
      };
    };
  };
}
