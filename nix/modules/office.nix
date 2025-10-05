{ isDarwin, isLinux, lib, pkgs, ... }:
lib.mkMerge [
  (lib.optionalAttrs isDarwin {
    homebrew.masApps = {
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Word" = 462054704;
      "OneDrive" = 823766827;
    };
  })

  (lib.optionalAttrs isLinux {
    environment.systemPackages = with pkgs; [
      libreoffice
    ];
  })
]
