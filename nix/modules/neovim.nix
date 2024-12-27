{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fd
    fzf
    neovim
    ripgrep
  ];
}
