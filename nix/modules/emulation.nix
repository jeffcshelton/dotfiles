{ lib, pkgs, isLinux, ... }:
lib.mkMerge [
  {
    environment.systemPackages = with pkgs; [
      qemu
    ];
  }

  (lib.optionalAttrs isLinux {
    # Enable foreign binary emulation.
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    # Link /bin/sh to bash for script compatibility.
    environment.binsh = "${pkgs.bash}/bin/bash";
  })
]
