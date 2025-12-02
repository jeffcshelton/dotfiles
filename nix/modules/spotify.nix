{ pkgs, ... }:
let
  # FIXME: Temporary fix for #465676. Remove when fixed.
  spotify = pkgs.spotify.overrideAttrs (old: {
    src = if (pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64)
      then pkgs.fetchurl {
        url = "https://web.archive.org/web/20251029235406/https://download.scdn.co/SpotifyARM64.dmg";
        hash = "sha256-0gwoptqLBJBM0qJQ+dGAZdCD6WXzDJEs0BfOxz7f2nQ=";
      }
      else old.src;
  });
in
{
  environment.systemPackages = [
    spotify
  ];
}
