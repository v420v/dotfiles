-- ─── Neovim ── Catppuccin Mocha rice ─────────────────────────
-- Entry point: load core config, then hand off to lazy.nvim.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.lazy")
