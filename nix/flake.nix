{
  description = "Jeff's Personal Flake";

  inputs = {
    agenix.url = "github:ryantm/agenix";
    asahi.url = "github:nix-community/nixos-apple-silicon";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    website.url = "github:jeffcshelton/shelton.one";
  };

  outputs = { darwin, home-manager, nixpkgs, ... } @ inputs:
  rec {
    darwinConfigurations = {
      mercury = darwin.lib.darwinSystem {
        modules = [ ./hosts/mercury.nix ];
        specialArgs = { inherit inputs; };
        system = "aarch64-darwin";
      };
    };

    nixosConfigurations = {
      ceres = nixpkgs.lib.nixosSystem {
	      modules = [ ./hosts/ceres.nix ];
        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
      };

      jupiter = nixpkgs.lib.nixosSystem {
        modules = [ home-manager.nixosModules.home-manager ./hosts/jupiter.nix ];
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
      };

      mars = nixpkgs.lib.nixosSystem {
        modules = [ ./hosts/mars.nix ];
        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
      };

      venus = nixpkgs.lib.nixosSystem {
        modules = [ ./hosts/venus.nix ];
        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
      };
    };

    image.mars =
      let
        nixosConfig = nixosConfigurations.mars;
        pkgs = nixosConfig.pkgs;
        script = nixosConfig.config.system.build.diskoImagesScript;
      in
      pkgs.stdenv.mkDerivation {
        pname = "mars-img";
        version = "1.0.0";

        dontUnpack = true;
        src = null;
        nativeBuildInputs = [ pkgs.bash ];

        buildPhase = ''
          ${script} --build-memory 2048
        '';

        installPhase = ''
          mv main.raw $out
        '';

        # Skip the fixup phase because it attempts to scan the disk image for
        # Nix store paths, which is unnecessary and takes a while.
        fixupPhase = ":";
      };
  };
}
