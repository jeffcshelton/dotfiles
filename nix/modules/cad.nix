# Packages and programs related to CAD.

{ pkgs, unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    openscad-unstable
    # unstable.prusa-slicer
  ];
}
