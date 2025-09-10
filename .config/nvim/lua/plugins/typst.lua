return {
  "chomosuke/typst-preview.nvim",
  lazy = false,
  version = "1.*",
  ft = "typst",
  opts = {
    invert_colors = "auto",
  },
  keys = {
    {
      "<leader>v",
      ":TypstPreviewToggle<CR>",
      desc = "Toggle the Typst preview.",
    }
  },
}
