# Packages and programs related to photo manipulation.

{ isDarwin, isLinux, lib, pkgs, ... }:
lib.mkMerge [
  (lib.optionalAttrs isDarwin {
    homebrew.masApps."Pixelmator Pro" = 1289583905;
  })

  (lib.optionalAttrs isLinux {
    environment.systemPackages = with pkgs; [
      gimp
    ];
  })
]
