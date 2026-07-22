local parsers = {
  "c",
  "html",
  "java",
  "javascript",
  "lua",
  "python",
  "rust",
  "typescript",
  "typst",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    require("nvim-treesitter").install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = parsers,
      callback = function(event)
        if vim.treesitter.language.add(event.match) then
          vim.treesitter.start(event.buf)
        end
      end,
    })
  end,
}
