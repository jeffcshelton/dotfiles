return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {
      filters = {
        custom = { ".DS_Store" },
        dotfiles = false,
        git_ignored = false,
      },
      git = {
        ignore = false,
      },
      renderer = {
        group_empty = true,
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "+",
              arrow_open = "-",
            },
          },
        },
      },
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
      },
    }
  end,
}
