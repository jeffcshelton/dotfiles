return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("claude-code").setup()
  end,
  keys = {
    {
      "<leader>ca",
      ":ClaudeCode<CR>",
    },
    {
      "<leader>cc",
      ":ClaudeCodeContinue<CR>",
    },
    {
      "<leader>cr",
      ":ClaudeCodeResume<CR>",
    },
  },
}
