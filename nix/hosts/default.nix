{
  darwin,
  flake-utils,
  nixpkgs,
  nixpkgs-unstable,
  self,
  ...
} @ inputs:
let
  inherit (nixpkgs) lib;

  # Read the hosts directory to determine all the systems in use.
  systems = builtins.attrNames
    (lib.filterAttrs
      (name: type: type == "directory")
      (builtins.readDir ./.)
    );

  # Filter for only the Darwin system targets.
  darwinSystems = builtins.filter
    (system: lib.strings.hasSuffix "darwin" system)
    systems;

  # Filter for only the Linux (NixOS) system targets.
  linuxSystems = builtins.filter
    (system: lib.strings.hasSuffix "linux" system)
    systems;

  inferHosts = (system:
    lib.mapAttrsToList
      (name: _type: lib.removeSuffix ".nix" name)
      (lib.filterAttrs
        (name: type: lib.hasSuffix ".nix" name && type == "regular")
        (builtins.readDir ./${system})
      )
  );

  mkHost = (config: config.builder (
    let
      inherit (config) host system;
    in
    {
      inherit system;
      modules = [ ./${config.system}/${config.host}.nix ];

      specialArgs = rec {
        inherit host inputs system;

        isDarwin = lib.hasSuffix "darwin" config.system;
        isLinux = lib.hasSuffix "linux" config.system;

        modulesName =
          if isDarwin then "darwinModules"
          else if isLinux then "nixosModules"
          else "unknown";

        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    } // (config.extra or {})
  ));

  # Determines the actual hosts present per system provided, using the system
  # directory's listing. Each Nix file is a unique host configuration.
  mkHosts = (config:
    lib.foldl'
      (all: current: all // current)
      {}
      (builtins.map
        (system:
          lib.genAttrs
            (inferHosts system)
            (host: mkHost {
              inherit host system;
              inherit (config) builder;
              extra = config.extra or {};
            })
        )
        config.systems
      )
  );
in
{
  darwinConfigurations = mkHosts {
    builder = darwin.lib.darwinSystem;
    systems = darwinSystems;
  };

  nixosConfigurations = mkHosts {
    builder = nixpkgs.lib.nixosSystem;
    systems = linuxSystems;
  };
}
// flake-utils.lib.eachDefaultSystem (system: {
  packages.images.mars =
    self.nixosConfigurations.mars.config.system.build.sdImage;
})
