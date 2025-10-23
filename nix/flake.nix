{
  description = "Jeff's Personal Flake";

  inputs = {
    agenix.url = "github:ryantm/agenix";
    asahi.url = "github:nix-community/nixos-apple-silicon";

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    portal-labs-cc.url = "github:jeffcshelton/portal-labs.cc";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    shelton-one.url = "github:jeffcshelton/shelton.one";
  };

  outputs = { nixos-generators, ... } @ inputs:
    let
      hosts = import ./hosts inputs;
    in
    hosts // {
      images.mars = nixos-generators.nixosGenerate {
        format = "sd-aarch64";
        modules = [ ./hosts/aarch64-linux/mars.nix ];
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs;
          system = "aarch64-linux";
          isDarwin = false;
          isLinux = true;
        };
      };
    };
}
