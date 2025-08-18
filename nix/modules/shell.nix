{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    starship
    tmux
  ];

  programs.zsh.enable = true;
}
