-- Window navigation mappings.
vim.keymap.set("n", "<leader>\\", ":vsplit<CR>")
vim.keymap.set("n", "<leader>[", ":wincmd h<CR>")
vim.keymap.set("n", "<leader>]", ":wincmd l<CR>")

-- Telescope commands.
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>f", telescope.live_grep)
vim.keymap.set("n", "<leader>p", telescope.find_files)
