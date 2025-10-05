{ isDarwin, lib, pkgs, ... }:
lib.mkMerge [
  {
    environment.systemPackages = with pkgs; [
      obsidian
    ];
  }

  (lib.optionalAttrs isDarwin {
    environment.systemPackages = with pkgs; [
      notion-app
    ];
  })
]
