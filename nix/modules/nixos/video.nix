# Packages related to video playback and editing.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # KDenLive video editor.
    kdePackages.kdenlive
    vlc
  ];
}
