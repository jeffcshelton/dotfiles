{ config, host, inputs, isDarwin, isLinux, lib, modulesName, pkgs, ... }:
let
  cfg = config.jeff;
  home = if isDarwin then "/Users/jeff" else "/home/jeff";
  dotfiles = "${home}/dotfiles";
  keys = import ../secrets/keys;

  # Hosts whose SSH key for jeff is generated here, rather than on the machine
  # itself, keep it encrypted alongside the public key.
  managedKey = ../secrets/keys/${host}/jeff.pem.age;
in
{
  imports = [
    inputs.agenix.${modulesName}.default
    inputs.home-manager.${modulesName}.default
  ];

  options.jeff.desktop = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Whether jeff gets desktop applications and file sync. Headless servers
      go without both.
    '';
  };

  config = lib.mkMerge [
    {
      home-manager.users.jeff = { config, lib, ... }:
        let
          inherit (config.lib.file) mkOutOfStoreSymlink;

          dotConfig = builtins.listToAttrs (
            map (name: {
              name = ".config/${name}";
              value.source = mkOutOfStoreSymlink "${dotfiles}/.config/${name}";
            })
            (builtins.attrNames (builtins.readDir ../../.config))
          );
        in
        {
          _module.args = { inherit host; };
          imports = [
            inputs.agenix.homeManagerModules.default
          ] ++ lib.optional cfg.desktop ./jeff/syncthing.nix;

          home = {
            username = "jeff";
            homeDirectory = home;
            stateVersion = "25.05";

            file = dotConfig // {
              ".zshrc".source = mkOutOfStoreSymlink "${dotfiles}/.zshrc";
            };

            # The links above point into the working copy, so fetch it on
            # machines that have none yet. A failed clone only warns, leaving
            # the links dangling until the next activation tries again.
            activation.cloneDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              if [ ! -e ${lib.escapeShellArg dotfiles} ]; then
                GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -o StrictHostKeyChecking=accept-new" \
                  run ${lib.getExe pkgs.git} clone git@shelton.one:jeff/dotfiles.git \
                    ${lib.escapeShellArg dotfiles} \
                  || warnEcho "Could not clone the dotfiles into ${dotfiles}."
              fi
            '';
          };

          programs.firefox = lib.mkIf cfg.desktop {
            enable = true;
            configPath = "${home}/.config/mozilla/firefox";

            profiles.default = {
              search = {
                default = "google";
                force = true;
                privateDefault = "google";
              };

              settings = {
                "browser.startup.homepage" = "https://www.google.com";
                "browser.search.defaultenginename" = "Google";
                "privacy.trackingprotection.enabled" = true;
              };
            };
          };
      };

      users.users.jeff = lib.mkMerge [
        {
          inherit home;
          description = "Jeff Shelton";
          shell = pkgs.zsh;

          openssh.authorizedKeys.keys = with keys; [
            ceres.jeff
            jupiter.jeff
            mercury.jeff
            neptune.jeff
          ];
        }

        (lib.optionalAttrs isLinux {
          isNormalUser = true;
          extraGroups = [
            "audio"
            "dialout"
            "docker"
            "i2c"
            "input"
            "kvm"
            "libvirtd"
            "lp"
            "networkmanager"
            "render"
            "scanner"
            "seat"
            "video"
            "wheel"
          ];
        })
      ];
    }

    # The decrypted key stays under agenix's runtime directory, so it never
    # depends on the home directory existing or being owned correctly at
    # activation. SSH is pointed at it for every connection jeff makes.
    (lib.optionalAttrs (builtins.pathExists managedKey) {
      age.secrets.jeff-ssh-key = {
        file = managedKey;
        owner = "jeff";
      };

      programs.ssh.extraConfig = ''
        Match localuser jeff
          IdentityFile ${config.age.secrets.jeff-ssh-key.path}
      '';
    })
  ];
}
