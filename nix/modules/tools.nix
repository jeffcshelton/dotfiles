{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    clang
    curl
    direnv
    file
    git
    nodejs_23
    python3
    stow
    wget
  ];

  programs.zsh.enable = true;
}
