return {
  "johnseth97/codex.nvim",
  lazy = true,
  keys = {
    {
      "<leader>a",
      function() require("codex").toggle() end,
      desc = "Toggle Codex",
    },
  },
  opts = {
    -- The Codex CLI is managed by Nix.
    autoinstall = false,
  },
}
