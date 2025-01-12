{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Provides clangd, the C language server.
    clang-tools

    fd

    # Fuzzy-finder used by the Telescope plugin.
    fzf

    # Lua 5.1, required for LuaRocks integration.
    lua51Packages.lua

    # The Lua package manager.
    # All Lua packages are managed declaratively through the Neovim config.
    lua51Packages.luarocks

    lua51Packages.magick

    neovim

    # Python language server.
    pyright

    # Enables support for embedded Jupyter notebooks.
    python313Packages.ipykernel

    ripgrep

    # TypeScript language server.
    typescript-language-server
  ];
}
