# Packages and programs related to photo manipulation.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gimp
  ];
}
