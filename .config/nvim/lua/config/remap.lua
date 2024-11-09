-- Remap brackets to navigate back and forth between the tree and editor.
vim.keymap.set("n", "<leader>[", ":NvimTreeFocus<CR>")
vim.keymap.set("n", "<leader>]", ":wincmd p<CR>")

-- Map Telescope commands.
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>p", telescope.find_files)
vim.keymap.set("n", "<leader>f", telescope.live_grep)
