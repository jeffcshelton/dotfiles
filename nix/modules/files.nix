{ isDarwin, isLinux, lib, pkgs, ... }:
lib.mkMerge [
  (lib.optionalAttrs isDarwin {
    system.defaults.finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "Nlsv";
    };
  })

  (lib.optionalAttrs isLinux {
    environment.systemPackages = with pkgs; [
      gnome-icon-theme
      gnome-themes-extra
      nautilus
    ];
  })
]
