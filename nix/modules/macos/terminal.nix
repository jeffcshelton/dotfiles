{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    starship
    tmux
  ];

  homebrew.casks = [ "iterm2" ];
  programs.zsh.enable = true;
}
