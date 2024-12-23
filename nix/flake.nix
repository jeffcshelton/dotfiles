{
  description = "Jeff's Personal Flake";

  inputs = {
    darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, darwin, nixpkgs }: {
    darwinConfigurations = {
      mercury = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./hosts/mercury.nix ];
      };
    };

    nixosConfigurations = {
      ceres = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
	      modules = [ ./hosts/ceres.nix ];
      };

      jupiter = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/jupiter.nix ];
      };
    };
  };
}
