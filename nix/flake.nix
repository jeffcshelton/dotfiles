{
  description = "Jeff's Personal Flake";

  inputs = {
    agenix.url = "github:ryantm/agenix";
    asahi.url = "github:nix-community/nixos-apple-silicon";

    darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin";
    };

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    website.url = "github:jeffcshelton/shelton.one";
  };

  outputs = {
    agenix,
    darwin,
    home-manager,
    nixos-generators,
    nixos-hardware,
    nixpkgs,
    website,
    ...
  } @ inputs:
  let
    # Modules that should be included for all machines.
    darwinModules = [
      agenix.darwinModules.default
      home-manager.darwinModules.home-manager
    ];

    nixosModules = [
      agenix.nixosModules.default
      home-manager.nixosModules.home-manager
      website.nixosModules.default
    ];
  in {
    darwinConfigurations = {
      mercury = darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        system = "aarch64-darwin";
        modules = darwinModules ++ [ ./hosts/mercury.nix ];
      };
    };

    nixosConfigurations = {
      ceres = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
	      modules = nixosModules ++ [ ./hosts/ceres.nix ];
      };

      jupiter = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = nixosModules ++ [ ./hosts/jupiter.nix ];
      };

      mars = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
        modules = nixosModules ++ [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./hosts/mars.nix
        ];
      };
    };

    img.mars = nixos-generators.nixosGenerate {
      format = "sd-aarch64";
      system = "aarch64-linux";
      modules = nixosModules ++ [
        nixos-hardware.nixosModules.raspberry-pi-4
        ./hosts/mars.nix
      ];
    };
  };
}
