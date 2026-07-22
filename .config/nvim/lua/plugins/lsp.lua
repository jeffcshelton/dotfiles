-- TODO: Consider moving to the new, native LSP API.
return {
  "neovim/nvim-lspconfig",
  cmd = { "LspInfo", "LspStart" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
  },
  event = { "BufReadPre", "BufNewFile" },
  lazy = false,
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
      "omnisharp",
      "openscad_lsp",
      "pyright",
      "rust_analyzer",
      "sourcekit",
      "tinymist",
      "ts_ls",
    }

    -- Configure Java-specific settings.
    local java_settings = {
      java = {
        autobuild = {
          enabled = false,
        },
      },
    }

    local gradle_java_home = vim.env.JDTLS_GRADLE_JAVA_HOME

    if gradle_java_home and vim.fn.isdirectory(gradle_java_home) == 1 then
      java_settings.java.import = {
        gradle = {
          java = {
            home = gradle_java_home,
          },
        },
      }
    end

    for _, server in ipairs(servers) do
      local config = { capabilities = capabilities }

      -- Apply Java configuration.
      if server == "jdtls" then
        config.settings = java_settings
        config.init_options = { settings = java_settings }
      end

      vim.lsp.config(server, config)
      vim.lsp.enable(server)
    end
  end,
}
