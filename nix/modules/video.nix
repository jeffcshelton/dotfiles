# Packages related to video playback and editing.

{ isDarwin, isLinux, lib, pkgs, ... }:
lib.mkMerge [
  (lib.optionalAttrs isDarwin {
    homebrew.masApps."iMovie" = 408981434;
  })

  (lib.optionalAttrs isLinux {
    environment.systemPackages = with pkgs; [
      # KDenLive video editor.
      kdePackages.kdenlive
      vlc
    ];
  })
]
