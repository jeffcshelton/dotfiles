-- TODO: Consider moving to the new, native LSP API.
return {
  "neovim/nvim-lspconfig",
  cmd = { "LspInfo", "LspStart" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP Actions",
      callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
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
      "sourcekit",
      "tinymist",
      "ts_ls",
    }

    for _, server in ipairs(servers) do
      vim.lsp.config(server, {
        capabilities = capabilities,
      })
      vim.lsp.enable(server)
    end
  end,
  lazy = false,
}
