local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.termguicolors = true
opt.showmode = false
opt.cmdheight = 1
opt.pumheight = 12
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " " }

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.autoread = true
opt.updatetime = 250
opt.timeoutlen = 400

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
    callback = function()
        if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then vim.cmd("checktime") end
    end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
    callback = function() vim.notify("File changed on disk, buffer reloaded", vim.log.levels.INFO) end,
})

opt.splitright = true
opt.splitbelow = true

opt.clipboard = "unnamedplus"

opt.mouse = "a"

opt.completeopt = { "menu", "menuone", "noselect" }

opt.lazyredraw = false
opt.synmaxcol = 300

local two_space = vim.api.nvim_create_augroup("TwoSpaceIndent", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = two_space,
    pattern = {
        "html",
        "css",
        "scss",
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "json",
        "jsonc",
        "yaml",
        "lua",
        "nix",
    },
    callback = function()
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.softtabstop = 2
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = two_space,
    pattern = "go",
    callback = function()
        vim.bo.expandtab = false
        vim.bo.shiftwidth = 4
        vim.bo.tabstop = 4
        vim.bo.softtabstop = 0
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 }) end,
})

vim.filetype.add({
    extension = { v = "v", vsh = "v", vv = "v" },
})

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
