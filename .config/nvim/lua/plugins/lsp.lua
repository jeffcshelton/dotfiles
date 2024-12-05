return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "ms-jpq/coq_nvim", branch = "coq" },
    { "ms-jpq/coq.artifacts", branch = "artifacts" },
    { "ms-jpq/coq.thirdparty", branch = "3p" },
    { "williamboman/mason.nvim" },
  },
  init = function()
    vim.g.coq_settings = {
      auto_start = "shut-up",
      completion = {
        always = false
      }
    }
  end,
  config = function()
    local lspconfig = require("lspconfig")
    local mason = require("mason")
    local coq = require("coq")

    mason.setup()

    -- Configure Rust-specific LSP settings.
    lspconfig.rust_analyzer.setup({})
    lspconfig.ts_ls.setup({})
  end,
  lazy = false,
}
