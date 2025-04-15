{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nixos-generators
  ];
}
