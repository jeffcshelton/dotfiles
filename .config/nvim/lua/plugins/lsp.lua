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

    -- Language servers to activate automatically.
    local servers = {
      "clangd",
      "jdtls",
      "lua_ls",
      "marksman",
      "nixd",
      "openscad_lsp",
      "pyright",
      "rust_analyzer",
      "tinymist",
      "ts_ls",
    }

    for _, server in ipairs(servers) do
      lspconfig[server].setup({})
    end
  end,
  lazy = false,
}
