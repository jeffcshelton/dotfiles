{ pkgs, ... }:
{
  home = {
    packages = [
      pkgs.clang
      pkgs.direnv
      pkgs.neovim
      pkgs.nodejs_23
      pkgs.python3
      pkgs.ripgrep
      pkgs.rustup
      pkgs.starship
      pkgs.stow
      pkgs.tmux
      pkgs.zsh
    ];

    # The state version that home-manager was originally installed with.
    stateVersion = "24.11";
  };

  programs = {
    git = {
      enable = true;
      userEmail = "jeff@shelton.one";
      userName = "Jeff Shelton";
    };

    home-manager.enable = true;
    htop.enable = true;
    man.enable = true;
  };
}
