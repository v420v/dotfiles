local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save buffer" })
map("n", "<leader>q", "<cmd>confirm quit<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit all" })

map("n", "Y", "y$", { desc = "Yank to end of line" })
map("n", "n", "nzzzv", { desc = "Next match centred" })
map("n", "N", "Nzzzv", { desc = "Prev match centred" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down centred" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up centred" })

map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Grow window vertical" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shrink window vertical" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Shrink window horizontal" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Grow window horizontal" })

map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })

map({ "n", "v" }, "<leader>p", [["_dP]], { desc = "Paste without yank" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yank" })

map("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tD", "<cmd>windo bdelete<CR>", { desc = "Delete all bufs in tab" })

map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

local function font_size(arg) vim.system({ "kitty", "@", "set-font-size", arg }) end
map("n", "<C-=>", function() font_size("+1") end, { desc = "Font size up" })
map("n", "<C-->", function() font_size("-1") end, { desc = "Font size down" })
map("n", "<C-0>", function() font_size("0") end, { desc = "Font size reset" })
