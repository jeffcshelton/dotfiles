{ pkgs, ... }:
{
  # Wrap the GNOME control center so that it thinks it's running under GNOME.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "gnome-control-center" ''
      XDG_CURRENT_DESKTOP=GNOME exec ${pkgs.gnome-control-center}/bin/gnome-control-center "$@"
    '')
  ];

  programs.dconf.enable = true;

  # Enable the keyring to be unlocked at login, avoiding pop-ups.
  security.pam.enableGnomeKeyring = true;

  # Use GNOME calendar as the calendar app, even outside of the GNOME DE.
  services.gnome = {
    evolution-data-server.enable = true;
    gnome-keyring.enable = true;
    gnome-online-accounts.enable = true;
  };
}
