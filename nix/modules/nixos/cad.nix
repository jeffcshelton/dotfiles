# Packages and programs related to CAD.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kicad
    openscad
    prusa-slicer
  ];
}
