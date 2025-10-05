# Packages and configuration related to supporting VPN connections.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    openconnect
    openvpn
  ];
}
