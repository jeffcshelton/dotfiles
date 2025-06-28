# General developer tools.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    autoconf
    bison
    ccache
    clang
    cmake
    curl
    devenv
    direnv
    file
    flex
    gcc
    git
    gnumake
    gnupg
    nodejs
    python3
    stow
    wget
    zip
  ];

  programs.zsh.enable = true;
}
