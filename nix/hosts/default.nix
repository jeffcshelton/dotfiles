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

  linuxHostSystems = lib.listToAttrs (lib.concatMap
    (system: map
      (host: lib.nameValuePair host system)
      (inferHosts system)
    )
    linuxSystems
  );

  linuxHosts = builtins.attrNames linuxHostSystems;

  # Each guest gets a stable loopback address used only on the VM runner.
  vmGuests = lib.listToAttrs
    (lib.imap0
      (index: host: lib.nameValuePair host {
        address = "127.0.1.${toString (index + 2)}";
        domain = "${host}.vm.shelton.one";
      })
      linuxHosts
    );

  mkHost = (config: config.builder (
    let
      inherit (config) host system;
    in
    {
      inherit system;
      modules = [ ./${config.system}/${config.host}.nix ]
        ++ lib.optional (config.vmHostSystem or null != null) {
          virtualisation.vmVariant.imports = [
            ../modules/vm.nix
          ];
        };

      specialArgs = rec {
        inherit host inputs system vmGuests;
        vmHostSystem = config.vmHostSystem or null;

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

  nixosHosts = mkHosts {
    builder = nixpkgs.lib.nixosSystem;
    systems = linuxSystems;
  };

  mkVmConfiguration = host: vmHostSystem:
    let
      nixos = mkHost {
        inherit host vmHostSystem;
        system = linuxHostSystems.${host};
        builder = nixpkgs.lib.nixosSystem;
      };
    in
    nixos // {
      config = nixos.config.virtualisation.vmVariant;
    };

  # Expose each evaluated VM configuration as a deployment target so local
  # changes can be activated in a running guest with nixos-rebuild.
  # Keep NixOS rebuild targets for the local Linux runner. Packages below add
  # equivalent runners for every supported flake output platform.
  vmConfigurations = lib.genAttrs linuxHosts
    (host: mkVmConfiguration host "x86_64-linux");

  # A small Linux appliance used only when flashing from Darwin. It receives
  # the QCOW2 overlay as a virtio disk, injects the encrypted host key, and
  # powers off. The target SD image remains a reusable store path.
  sshInjectorAppliance = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ ../derivations/ssh-injector-appliance.nix ];
  };
in
{
  darwinConfigurations = mkHosts {
    builder = darwin.lib.darwinSystem;
    systems = darwinSystems;
  };

  nixosConfigurations = nixosHosts
    // lib.mapAttrs'
      (host: nixos: lib.nameValuePair "${host}-vm" nixos)
      vmConfigurations;
}
// flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };
  in
  {
    packages = {
      images.mars =
        self.nixosConfigurations.mars.config.system.build.sdImage;

      flash.mars = import ../derivations/flasher.nix {
        inherit pkgs;
        image = self.nixosConfigurations.mars.config.system.build.sdImage;
        host = "mars";
        secrets = ../secrets/keys;
        injectorIso = sshInjectorAppliance.config.system.build.isoImage;
      };
      vm = lib.genAttrs linuxHosts
        (host: (mkVmConfiguration host system).config.system.build.vm);
    };
  }
)
