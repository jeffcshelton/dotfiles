# A minimal NixOS installer that accepts SSH from personal machines as soon as
# it boots, so nixos-anywhere can install a headless host remotely.
#
# The stock kernel is used to stay binary-cached. It lacks T2 keyboard and
# Wi-Fi support, so connect USB or Thunderbolt Ethernet before booting.

{ lib, modulesPath, ... }:
let
  keys = import ../secrets/keys;
in
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

  # Advertise installer.local so the installing machine can find it without
  # checking the router for its address.
  networking.hostName = "installer";

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.openssh.settings.PasswordAuthentication = lib.mkForce false;

  users.users.root.openssh.authorizedKeys.keys = with keys; [
    ceres.jeff
    jupiter.jeff
    mercury.jeff
  ];
}
