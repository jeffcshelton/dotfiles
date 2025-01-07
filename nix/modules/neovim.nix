{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Provides clangd, the C language server.
    clang-tools

    fd

    # Fuzzy-finder used by the Telescope plugin.
    fzf

    neovim

    # Python language server.
    pyright

    ripgrep

    # TypeScript language server.
    typescript-language-server
  ];
}
