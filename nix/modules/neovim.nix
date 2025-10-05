# Packages required for Neovim.
#
# The Neovim configuration is not kept in Nix; it's written in Lua and symlinked
# directly into ~/.config using GNU Stow.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Provides clangd, the C language server.
    clang-tools

    # Enables AI code editing.
    claude-code

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

    # OpenSCAD language server.
    openscad-lsp

    # Python language server.
    pyright

    # Enables quick searching of text throughout a project.
    ripgrep

    # Swift and Objective-C language server.
    sourcekit-lsp

    # Typst language server.
    tinymist

    # Tree sitter incremental parser.
    tree-sitter

    # TypeScript language server.
    typescript-language-server
  ];
}
