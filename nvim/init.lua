vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.errorlog")
require("config.lazy")
require("config.dnd")
require("config.claude_status").setup({ poll_ms = 3000 })
