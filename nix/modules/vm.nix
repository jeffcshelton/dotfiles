{ config, host, inputs, lib, pkgs, vmGuests, vmHostSystem, ... }:
let
  guest = vmGuests.${host};

  forwardPort = port: {
    host.address = guest.address;
    host.port = if port == 22 then 2222 else port;
    guest.port = port;
  };
in
{
  imports = [
    ./server/tunnel.nix
  ];

  # Production tunnels and their credentials must not run in local VMs.
  server.cloudflare.enable = lib.mkForce false;

  # Replace hardware-specific kernels and storage activation only in the VM.
  boot = {
    growPartition = lib.mkForce false;
    kernelPackages = lib.mkForce pkgs.linuxPackages;
  };

  virtualisation = {
    # This is the platform executing QEMU, not the guest's NixOS platform.
    host.pkgs = import inputs.nixpkgs {
      system = vmHostSystem;
    };

    cores = 4;
    diskImage = null;
    graphics = false;
    memorySize = 2048;

    # Mirror each service already exposed by the guest firewall. SSH uses a
    # high host port; Jupiter's SSH config selects it transparently.
    forwardPorts = map forwardPort
      (lib.unique config.networking.firewall.allowedTCPPorts);
  };
}
