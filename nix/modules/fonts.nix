# Font packages.

{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-mono
  ];
}
