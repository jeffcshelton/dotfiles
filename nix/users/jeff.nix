{ host, inputs, isDarwin, isLinux, lib, modulesName, pkgs, ... }:
let
  dotConfig = builtins.listToAttrs
  (
    map (name: {
      name = ".config/${name}";
      value = {
        source = ../../.config/${name};
        recursive = true;
      };
    })
    (builtins.attrNames (builtins.readDir ../../.config))
  );

  home = if isDarwin then "/Users/jeff" else "/home/jeff";
  keys = import ../secrets/keys;
in
{

  imports = [
    inputs.home-manager.${modulesName}.default
  ];

  home-manager.users.jeff = {
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
        ".zshrc".source = ../../.zshrc;
      };
    };

    programs = {
      firefox = {
        enable = true;

        profiles.default = {
          search = {
            default = "ddg";
            force = true;
            privateDefault = "ddg";
          };

          settings = {
            "browser.startup.homepage" = "https://www.perplexity.ai";
            "browser.search.defaultenginename" = "DuckDuckGo";
            "privacy.trackingprotection.enabled" = true;
          };
        };
      };

      ssh = {
        enable = true;

        matchBlocks."ice" = {
          host = "ice";
          hostname = "login-ice.pace.gatech.edu";
          user = "jshelton44";
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
        "docker"
        "i2c"
        "input"
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
