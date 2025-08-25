{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    python3
    python3Packages.matplotlib
    python3Packages.numpy
    python3Packages.torch
    python3Packages.torchvision
  ];
}
