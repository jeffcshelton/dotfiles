{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    discord
    libreoffice
    obsidian
    postman
    spotify
    thunderbird
    zoom-us
  ];

  programs = {
    # Despite the strange names, these are the official 1Password packages.
    _1password.enable = true;
    _1password-gui.enable = true;

    steam.enable = true;
  };
}
