# Packages and programs related to CAD.

{ isDarwin, isLinux, lib, pkgs, ... }:
lib.mkMerge [
  {
    environment.systemPackages = with pkgs; [
      openscad-unstable
      # prusa-slicer
    ];
  }

  (lib.optionalAttrs isDarwin {
    # KiCad is marked as broken for Darwin targets.
    # See: https://github.com/NixOS/nixpkgs/issues/98203
    homebrew.casks = [ "kicad" ];
  })

  (lib.optionalAttrs isLinux {
    environment.systemPackages = with pkgs; [
      kicad
    ];
  })
]
