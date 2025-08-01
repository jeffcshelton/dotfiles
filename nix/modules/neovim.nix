# Packages required for Neovim.
#
# The Neovim configuration is not kept in Nix; it's written in Lua and symlinked
# directly into ~/.config using GNU Stow.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Provides clangd, the C language server.
    clang-tools

    # Enables quick searching of files by path.
    fd

    # Fuzzy-finder used by the Telescope plugin.
    fzf

    # An image manipulation tool that enables Neovim image display.
    imagemagick

    # Java language server.
    jdt-language-server

    # Lua language server.
    lua-language-server

    # Markdown language server.
    marksman

    # The Neovim editor itself.
    neovim

    # Nix language server.
    nixd

    # Enables running LLM models locally.
    ollama

    # OpenSCAD language server.
    openscad-lsp

    # Python language server.
    pyright

    # Enables support for embedded Jupyter notebooks.
    python313Packages.ipykernel

    # Enables quick searching of text throughout a project.
    ripgrep

    # Tree sitter incremental parser.
    tree-sitter

    # TypeScript language server.
    typescript-language-server
  ];
}
