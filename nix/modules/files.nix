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
    security.polkit.enable = true;

    services = {
      gvfs.enable = true;
      udisks2.enable = true;
    };

    environment.systemPackages = with pkgs; [
      gnome-icon-theme
      gnome-themes-extra
      nautilus
      udiskie
    ];
  })
]
