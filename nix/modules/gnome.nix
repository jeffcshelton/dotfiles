# GNOME desktop environment configuration.

{ isLinux, lib, pkgs, ... }:
lib.optionalAttrs isLinux {
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-maps
    gnome-music
    gnome-tour
    gnome-weather
    seahorse
    totem
    yelp
  ];

  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };
}
