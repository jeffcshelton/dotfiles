{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pandoc
    texliveFull
    typst
  ];
}
