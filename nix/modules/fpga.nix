# FPGA development support packages and configuration.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gtkwave
    verilator
  ];
}
