{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    clang
    curl
    direnv
    git
    neovim
    nodejs_23
    python3
    ripgrep
    starship
    stow
    tmux
    wget
  ];

  programs.zsh.enable = true;
}
