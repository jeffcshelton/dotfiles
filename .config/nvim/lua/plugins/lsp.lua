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
      auto_start = true,
    }
  end,
  config = function()
    local lspconfig = require("lspconfig")
    local mason = require("mason")

    mason.setup()
    lspconfig.rust_analyzer.setup({})
  end,
  lazy = false,
}
