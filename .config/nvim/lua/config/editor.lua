-- Disable netrw.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Configure line numbers.
vim.opt.number = true
vim.opt.relativenumber = true

-- Configure vertical line at 80 characters.
vim.opt.colorcolumn = "80"

-- Configure theme.
vim.opt.termguicolors = true
vim.cmd[[ colorscheme vscode ]]

-- Reserve a sign column to prevent layout shift.
vim.opt.signcolumn = "yes"

-- Configure a red background for trailing whitespace.
-- This is wrapped in an autocmd callback because some plugin is overriding
-- this configuration after being lazy-loaded.
vim.api.nvim_set_hl(0, "TrailingWhitespace", {
  ctermbg = "red",
  bg = "#631616",
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    vim.fn.matchadd("TrailingWhitespace", [[\s\+$]])
  end,
})

-- Set up a custom status line.
require("lualine").setup {
  options = {
    component_separators = "",
    disabled_filetypes = { "NvimTree" },
    icons_enabled = true,
    section_separators = { left = "", right = "" },
    theme = "auto",
  },
  sections = {
    lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
    lualine_b = { "filename", "branch" },
    lualine_c = { "%=" },
    lualine_x = {},
    lualine_y = { "filetype", "progress" },
    lualine_z = {
      { "location", separator = { right = "" }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { "filename" },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "location" },
  },
  tabline = {},
  extensions = {},
}
