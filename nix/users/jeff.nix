{ host, inputs, isDarwin, isLinux, lib, modulesName, pkgs, ... }:
let
  home = if isDarwin then "/Users/jeff" else "/home/jeff";
  dotfiles = "${home}/dotfiles";
  keys = import ../secrets/keys;
in
{
  imports = [
    inputs.home-manager.${modulesName}.default
  ];

  home-manager.users.jeff = { config, ... }:
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
        ./jeff/syncthing.nix
      ];

      home = {
        username = "jeff";
        homeDirectory = home;
        stateVersion = "25.05";

        file = dotConfig // {
          ".zshrc".source = mkOutOfStoreSymlink "${dotfiles}/.zshrc";
        };
      };

      programs.firefox = {
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
