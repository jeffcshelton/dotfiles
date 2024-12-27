{ ... }:
{
  services.xserver = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    enable = true;

    xkb = {
      layout = "us";
      options = "";
    };
  };
}
