{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    autoconf
    bison
    ccache
    clang
    cmake
    curl
    direnv
    file
    flex
    gcc
    git
    gnumake
    nodejs_23
    python3
    stow
    wget
    zip
  ];

  programs.zsh.enable = true;
}
