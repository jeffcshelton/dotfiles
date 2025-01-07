{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    blender
    openscad
  ];
}
