{ lib, pkgs, ... }:
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

  home = if pkgs.stdenv.isDarwin then "/Users/jeff" else "/home/jeff";
  keys = import ../keys;
in
{
  home-manager.users.jeff = {
    home = {
      username = "jeff";
      homeDirectory = home;
      stateVersion = "25.05";

      file = dotConfig // {
        ".codex" = {
          source = ../../.codex;
          recursive = true;
        };

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
        enableDefaultConfig = false;

        matchBlocks."ice" = {
          host = "ice";
          hostname = "login-ice.pace.gatech.edu";
          user = "jshelton44";
        };
      };
    };
  };

  users.users.jeff = {
    inherit home;
    description = "Jeff Shelton";
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = with keys; [
      ceres.jeff
      jupiter.jeff
      mercury.jeff
    ];
  } // (lib.optionalAttrs pkgs.stdenv.isLinux {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "docker"
      "i2c"
      "input"
      "kvm"
      "lp"
      "networkmanager"
      "render"
      "scanner"
      "seat"
      "video"
      "wheel"
    ];
  });
}
