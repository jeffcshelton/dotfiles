{
  description = "Jeff's Personal Flake";

  inputs = {
    darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
  };

  outputs = { darwin, nixpkgs, ... } @ inputs: {
    darwinConfigurations = {
      mercury = darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        system = "aarch64-darwin";
        modules = [ ./hosts/mercury.nix ];
      };
    };

    nixosConfigurations = {
      ceres = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
	      modules = [ ./hosts/ceres.nix ];
      };

      jupiter = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [ ./hosts/jupiter.nix ];
      };
    };
  };
}
