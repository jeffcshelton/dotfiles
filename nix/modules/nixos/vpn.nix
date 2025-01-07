{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    openconnect
    openvpn
  ];
}
