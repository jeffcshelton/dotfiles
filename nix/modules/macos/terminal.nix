{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    starship
    tmux
  ];

  homebrew.casks = [ "ghostty" ];
  programs.zsh.enable = true;
}
