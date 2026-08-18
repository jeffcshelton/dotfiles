{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    starship
    tmux
    zoxide
  ];

  programs.zsh.enable = true;
}
