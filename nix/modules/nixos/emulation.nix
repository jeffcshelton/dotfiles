{ pkgs, ... }:
{
  # Enable foreign binary emulation.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  environment = {
    # Link /bin/sh to bash for script compatibility.
    binsh = "${pkgs.bash}/bin/bash";

    systemPackages = with pkgs; [
      qemu
    ];
  };
}
