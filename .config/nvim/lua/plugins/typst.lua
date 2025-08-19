return {
  "chomosuke/typst-preview.nvim",
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
