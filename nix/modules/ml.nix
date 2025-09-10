{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (python3.withPackages (pypkgs: with pypkgs; [
      matplotlib
      numpy
      torch
      torchvision
    ]))
  ];
}
