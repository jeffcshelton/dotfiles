# Firefox configuration for the aarch64 platform.
#
# The Firefox package for this platform does not include Widevine CDM, which is
# required for playing DRM content such as Spotify music.

{ pkgs, ... }:
  let ffwv = pkgs.callPackage ../../../derivations/ffwv.nix {};
in {
  imports = [
    ../firefox.nix
  ];

  environment = {
    # The widevine-cdm package present in nixpkgs does not structure the files
    # as Firefox requires, so the derivation restructures them to fit.
    systemPackages = [ ffwv ];

    # Set an environment variable to tell Firefox where to find Widevine.
    variables.MOZ_GMP_PATH = "${ffwv}/gmp-widevinecdm/system-installed";
  };

  # Configure Firefox profile settings to enable Widevine.
  home-manager.users.jeff.programs.firefox.profiles.default.settings = {
    "media.gmp-widevinecdm.version" = "system-installed";
    "media.gmp-widevinecdm.visible" = true;
    "media.gmp-widevinecdm.enabled" = true;
    "media.gmp-widevinecdm.autoupdate" = false;
    "media.eme.enabled" = true;
    "media.eme.encrypted-media-encryption-scheme.enabled" = true;
  };
}
