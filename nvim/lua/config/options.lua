-- ─── Editor options ──────────────────────────────────────────
local opt = vim.opt

-- Display
opt.number         = true
opt.relativenumber = true
opt.signcolumn     = "yes"
opt.cursorline     = true
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.wrap           = false
opt.termguicolors  = true
opt.showmode       = false   -- lualine handles it
opt.cmdheight      = 1
opt.pumheight      = 12
opt.list           = true
opt.listchars      = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars      = { eob = " " }

-- Indentation (4-space default; ftplugin overrides per language)
opt.expandtab      = true
opt.shiftwidth     = 4
opt.tabstop        = 4
opt.softtabstop    = 4
opt.smartindent    = true

-- Search
opt.ignorecase     = true
opt.smartcase      = true
opt.hlsearch       = true
opt.incsearch      = true

-- Files / persistence
opt.undofile       = true
opt.swapfile       = false
opt.backup         = false
opt.updatetime     = 250
opt.timeoutlen     = 400

-- Splits
opt.splitright     = true
opt.splitbelow     = true

-- Wayland clipboard (wl-clipboard already in PATH)
opt.clipboard      = "unnamedplus"

-- Mouse
opt.mouse          = "a"

-- Completion behaviour
opt.completeopt    = { "menu", "menuone", "noselect" }

-- Faster macros / smoother scrolling
opt.lazyredraw     = false
opt.synmaxcol      = 300

-- Per-language indent overrides (web stack prefers 2 spaces)
local two_space = vim.api.nvim_create_augroup("TwoSpaceIndent", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group   = two_space,
    pattern = { "html", "css", "scss", "javascript", "typescript",
                "javascriptreact", "typescriptreact", "json", "jsonc",
                "yaml", "lua", "nix" },
    callback = function()
        vim.bo.shiftwidth  = 2
        vim.bo.tabstop     = 2
        vim.bo.softtabstop = 2
    end,
})

-- Go uses real tabs (gofmt convention)
vim.api.nvim_create_autocmd("FileType", {
    group   = two_space,
    pattern = "go",
    callback = function()
        vim.bo.expandtab    = false
        vim.bo.shiftwidth   = 4
        vim.bo.tabstop      = 4
        vim.bo.softtabstop  = 0
    end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 }) end,
})

-- Disable unused providers (NixOS-friendly: no Python/Ruby/Perl needed)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_perl_provider    = 0
vim.g.loaded_node_provider    = 0
