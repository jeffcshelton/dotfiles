# GNOME desktop environment configuration.

{ pkgs, ... }:
{
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

  services.xserver = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    enable = true;
  };
}
