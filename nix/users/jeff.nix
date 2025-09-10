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
in
{
  home = {
    username = "jeff";
    homeDirectory = "/home/jeff";
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
}
