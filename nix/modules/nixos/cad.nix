# Packages and programs related to CAD.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    freecad
    kicad
    openscad
    prusa-slicer
  ];
}
