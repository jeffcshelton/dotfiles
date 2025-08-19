return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c",
        "html",
        "javascript",
        "lua",
        "python",
        "rust",
        "typescript",
        "typst",
      },
      highlight = { enable = true },
    })
  end,
}
