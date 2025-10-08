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
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    portal-labs-cc.url = "path:/home/jeff/Dev/portal-labs.cc";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    shelton-one.url = "github:jeffcshelton/shelton.one";
  };

  outputs = inputs:
    let
      hosts = import ./hosts inputs;
    in
    hosts // {
      image.mars =
        let
          nixosConfig = hosts.nixosConfigurations.mars;
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
