return {
  "f-person/git-blame.nvim",
  event = "VeryLazy",
  opts = {
    date_format = "%r",
    enabled = false,
    message_template = "  <author> (<date>): <summary> [<sha>]",
  },
  keys = {
    {
      "<leader>gb",
      "<cmd>GitBlameToggle<CR>",
      desc = "Toggle inline Git blame.",
    }
  },
}
