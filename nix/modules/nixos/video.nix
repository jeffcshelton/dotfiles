{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # KDenLive video editor.
    kdePackages.kdenlive
  ];
}
