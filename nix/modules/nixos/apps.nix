{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    discord
    spotify
    zoom-us
  ];

  programs = {
    # Despite the strange names, these are the official 1Password packages.
    _1password.enable = true;
    _1password-gui.enable = true;
  };
}
