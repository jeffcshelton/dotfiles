-- TODO: Consider moving to the new, native LSP API.
return {
  "neovim/nvim-lspconfig",
  cmd = { "LspInfo", "LspInstall", "LspStart" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lspconfig = require("lspconfig")
    local defaults = lspconfig.util.default_config

    defaults.capabilities = vim.tbl_deep_extend(
      "force",
      defaults.capabilities,
      require("cmp_nvim_lsp").default_capabilities()
    )

    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP Actions",
      callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
      end,
    })

    lspconfig.clangd.setup({})
    lspconfig.nixd.setup({})
    lspconfig.pyright.setup({})
    lspconfig.rust_analyzer.setup({})
    lspconfig.ts_ls.setup({})
  end,
  lazy = false,
}
