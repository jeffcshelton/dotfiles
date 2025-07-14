-- Window navigation mappings.
vim.keymap.set("n", "<leader>\\", ":vsplit<CR>")
vim.keymap.set("n", "<leader>[", ":wincmd h<CR>")
vim.keymap.set("n", "<leader>]", ":wincmd l<CR>")

-- Telescope commands.
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>f", telescope.live_grep)
vim.keymap.set("n", "<leader>p", telescope.find_files)

-- LSP diagnostic commands.
vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>dN", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>dr", vim.diagnostic.reset)
