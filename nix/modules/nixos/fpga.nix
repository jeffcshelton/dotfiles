{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gtkwave
    verilator
  ];
}
