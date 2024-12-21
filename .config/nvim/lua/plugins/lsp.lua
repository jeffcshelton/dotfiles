return {
  "neovim/nvim-lspconfig",
  cmd = { "LspInfo", "LspInstall", "LspStart" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
    {
      "williamboman/mason.nvim",
      lazy = false,
      opts = {},
    },
    { "williamboman/mason-lspconfig.nvim" },
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lsp_defaults = require("lspconfig").util.default_config

    lsp_defaults.capabilities = vim.tbl_deep_extend(
      "force",
      lsp_defaults.capabilities,
      require("cmp_nvim_lsp").default_capabilities()
    )

    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP Actions",
      callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
      end,
    })

  end,
  lazy = false,
}
