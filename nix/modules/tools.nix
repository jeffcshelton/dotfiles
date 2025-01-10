{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    clang
    cmake
    curl
    direnv
    file
    gcc
    git
    gnumake
    nodejs_23
    python3
    stow
    wget
  ];

  programs.zsh.enable = true;
}
