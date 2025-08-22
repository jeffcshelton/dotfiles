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
        modules = darwinModules ++ [ ./hosts/mercury.nix ];
        specialArgs = { inherit inputs; };
        system = "aarch64-darwin";
      };
    };

    nixosConfigurations = {
      ceres = nixpkgs.lib.nixosSystem {
	      modules = nixosModules ++ [ ./hosts/ceres.nix ];
        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
      };

      jupiter = nixpkgs.lib.nixosSystem {
        modules = nixosModules ++ [ ./hosts/jupiter.nix ];
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
      };

      mars = nixpkgs.lib.nixosSystem {
        modules = nixosModules ++ [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./hosts/mars.nix
        ];

        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
      };

      venus = nixpkgs.lib.nixosSystem {
        modules = nixosModules ++ [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./hosts/venus.nix
        ];

        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
      };
    };

    image = {
      mars = nixos-generators.nixosGenerate {
        format = "sd-aarch64";
        modules = nixosModules ++ [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./hosts/mars.nix
        ];

        system = "aarch64-linux";
      };

      venus = nixos-generators.nixosGenerate {
        format = "sd-aarch64";
        modules = nixosModules ++ [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./hosts/venus.nix
        ];

        system = "aarch64-linux";
      };
    };
  };
}
