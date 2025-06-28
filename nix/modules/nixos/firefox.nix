# Browser configuration.

{ pkgs, ... }:
{
  environment = {
    sessionVariables = {
      MOZ_GMP_PATH = "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm/_platform_specific/linux_arm64";
    };

    systemPackages = with pkgs; [
      widevine-cdm
    ];
  };

  programs.firefox = {
    enable = true;

    # Enable external Widevine CDM support.
    # extraPrefs = {
    #   "media.gmp-widevinecdm.enable" = true;
    #   "media.gmp-manager.updateEnabled" = false;
    # };

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
}
