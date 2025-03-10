{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Provides clangd, the C language server.
    clang-tools

    fd

    # Fuzzy-finder used by the Telescope plugin.
    fzf

    neovim

    # Nix language server.
    nixd

    # An image manipulation tool that enables Neovim image display.
    imagemagick

    # Java language server.
    jdt-language-server

    # Python language server.
    pyright

    # Enables support for embedded Jupyter notebooks.
    python313Packages.ipykernel

    ripgrep

    # TypeScript language server.
    typescript-language-server
  ];
}
