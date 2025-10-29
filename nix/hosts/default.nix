{ darwin, nixpkgs, nixpkgs-unstable, ... } @ inputs:
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

  constructHosts = (systems: builder:
    let
      hosts = builtins.map (system:
        let
          entries = builtins.readDir ./${system};
          hostFiles = lib.filterAttrs
            (name: type: lib.hasSuffix ".nix" name && type == "regular")
            entries;
        in
        lib.mapAttrs' (hostFile: _:
          let
            host = lib.removeSuffix ".nix" hostFile;
          in
          {
            name = host;
            value = builder {
              inherit system;

              modules = [ ./${system}/${hostFile} ];
              specialArgs = rec {
                inherit host inputs system;

                isDarwin = lib.hasSuffix "darwin" system;
                isLinux = lib.hasSuffix "linux" system;

                modulesName =
                  if isDarwin then "darwinModules"
                  else if isLinux then "nixosModules"
                  else "unknown";

                unstable = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };
              };
            };
          }
        ) hostFiles
      ) systems;
    in
    (lib.foldl' (total: curr: total // curr) {} hosts)
  );

  # Construct Darwin and NixOS configurations.

  darwinConfigurations = constructHosts
    darwinSystems
    darwin.lib.darwinSystem;

  nixosConfigurations = constructHosts
    linuxSystems
    nixpkgs.lib.nixosSystem;

  # Automatically create image targets for the NixOS configurations.

  images = lib.mapAttrs
    (host: config:
      let
        inherit (config) pkgs;
        script = config.system.build.diskoImagesScript;
      in
      pkgs.stdenv.mkDerivation {
        pname = "${host}-image";
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
      }
    ) nixosConfigurations;
in
{
  inherit darwinConfigurations images nixosConfigurations;
}
