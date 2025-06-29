# Browser configuration.

{ ... }:
{
  programs.firefox = {
    enable = true;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      EnableTrackingProtection = {
        Cryptomining = true;
        Fingerprinting = true;
        Locked = true;
        Value = true;
      };
    };
  };

  home-manager.users.jeff.programs.firefox = {
    enable = true;

    profiles.default = {
      search = {
        default = "ddg";
        privateDefault = "ddg";

        engines = {
          "ddg" = {};
          "MyDocs" = {
            urls = [
              {
                template = "https://example.com/search?q={searchTerms}";
                params = [];
              }
            ];
          };
        };

        force = true;
      };

      settings = {
        "browser.startup.homepage" = "https://duckduckgo.com";
        "browser.search.defaultenginename" = "DuckDuckGo";
        "privacy.trackingprotection.enabled" = true;
      };
    };
  };
}
