{ isDarwin, lib, pkgs, ... }:
lib.mkMerge [
  {
    environment.systemPackages = with pkgs; [
      wireshark
    ];
  }

  (lib.optionalAttrs isDarwin {
    homebrew.casks = [ "wireshark-chmodbpf" ];
  })
]
