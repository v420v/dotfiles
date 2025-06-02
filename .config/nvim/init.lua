
vim.opt.number = true                -- Show line numbers
vim.opt.relativenumber = true        -- Show relative line numbers
vim.opt.cursorline = true            -- Highlight current line
vim.opt.mouse = 'a'                  -- Enable mouse support
vim.opt.clipboard = 'unnamedplus'    -- Use system clipboard
vim.opt.ignorecase = true            -- Case insensitive search
vim.opt.smartcase = true             -- Except when using capital letters
vim.opt.smartindent = true           -- Smart indenting
vim.opt.expandtab = true             -- Use spaces instead of tabs
vim.opt.tabstop = 2                  -- Tab = 2 spaces
vim.opt.shiftwidth = 2               -- Tab width for autoindent
vim.opt.softtabstop = 2              -- Number of spaces per tab in insert mode
vim.opt.wrap = false                 -- Don't wrap lines
vim.opt.termguicolors = true         -- True color support
vim.opt.hidden = true                -- Allow hiding buffers with unsaved changes
vim.opt.updatetime = 300             -- Faster completion
vim.opt.timeoutlen = 500             -- Time to wait for a mapped sequence
vim.opt.completeopt = 'menuone,noselect' -- Better completion experience
vim.opt.signcolumn = 'yes'           -- Always show the signcolumn
vim.opt.scrolloff = 8                -- Keep 8 lines above/below cursor when scrolling
vim.opt.sidescrolloff = 8            -- Keep 8 columns left/right of cursor when scrolling

-- Set leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager (packer.nvim)
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

-- Plugin setup
require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'

  -- Color scheme
  use "blazkowolf/gruber-darker.nvim"

  -- Status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- File explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  -- Buffer tabs
  use {'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons'}

  -- Syntax highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- LSP (Language Server Protocol)
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'

  -- Autocompletion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'

  -- Fuzzy finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Git integration
  use 'lewis6991/gitsigns.nvim'

  -- Autopairs
  use 'windwp/nvim-autopairs'

  -- Comment code
  use 'numToStr/Comment.nvim'

  -- Indent guides
  use 'lukas-reineke/indent-blankline.nvim'
end)

-- Color scheme setup
vim.cmd.colorscheme("gruber-darker")

-- Status line setup
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

-- File explorer setup
require('nvim-tree').setup {
  view = {
    width = 30,
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = true,
    ignore = false,
  },
  renderer = {
    highlight_git = true, -- ← Gitステータスの色付けを有効化
    icons = {
      show = {
        git = true,      -- ← Gitアイコンを表示
      },
      glyphs = {
        git = {
          unstaged  = "✗",  -- 変更あり
          staged    = "✓",  -- ステージ済み
          unmerged  = "",  -- マージコンフリクト
          renamed   = "➜",  -- リネーム
          untracked = "★",  -- 新規ファイル
          deleted   = "",  -- 削除
          ignored   = "◌",  -- .gitignore対象
        },
      },
    },
  },
}

-- Buffer line setup
require('bufferline').setup {
  options = {
    separator_style = "thin",
  }
}

-- Treesitter setup for syntax highlighting
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "lua", "go", "php", "javascript", "typescript", 
    "html", "css", "json", "yaml"
  },
  highlight = {
    enable = true,
  },
}

-- LSP (Language Server Protocol) setup
require('mason').setup({
  ui = {
    check_outdated_packages_on_open = true,
    border = "rounded",
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  },
  max_concurrent_installers = 4,
})

require('mason-lspconfig').setup {
  ensure_installed = {
    "phpactor",   -- Alternative PHP server
  },
  automatic_installation = true,
}

local lspconfig = require('lspconfig')

-- Configure LSP servers
-- PHP
lspconfig.phpactor.setup {}

-- Global LSP keybindings
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    
    -- Code navigation
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
    
    -- VSCode-like keybindings
    vim.keymap.set('n', 'F12', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<C-F12>', vim.lsp.buf.references, opts)       -- Find References
    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)              -- Rename Symbol
    vim.keymap.set('n', '<C-Space>', vim.lsp.buf.hover, opts)          -- Hover information
    vim.keymap.set('n', '<F8>', vim.diagnostic.goto_next, opts)        -- Go to next diagnostic
    vim.keymap.set('n', '<S-F8>', vim.diagnostic.goto_prev, opts)      -- Go to previous diagnostic
    
    -- Open definition in split (more VSCode-like behavior)
    vim.keymap.set('n', '<C-Enter>', function()
      vim.cmd('vsplit')                                              -- Split window vertically
      vim.lsp.buf.definition()                                       -- Go to definition in the new split
    end, opts)
    
    -- Preview definition (peek definition like in VSCode)
    vim.keymap.set('n', '<C-S-F12>', function()
      local position_params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, 'textDocument/definition', position_params, function(err, result, ctx, config)
        if result and #result > 0 then
          -- Create a temporary floating window to preview definition
          local width = math.floor(vim.o.columns * 0.7)
          local height = math.floor(vim.o.lines * 0.3)
          local buf = vim.api.nvim_create_buf(false, true)
          local opts = {
            relative = 'editor',
            width = width,
            height = height,
            col = math.floor((vim.o.columns - width) / 2),
            row = math.floor((vim.o.lines - height) / 2),
            style = 'minimal',
            border = 'rounded'
          }
          local win = vim.api.nvim_open_win(buf, false, opts)
          
          -- Jump to definition in the buffer
          local location = result[1]
          if location.targetUri then
            local uri = location.targetUri
            local range = location.targetRange or location.targetSelectionRange
            vim.api.nvim_buf_set_option(buf, 'filetype', 'php')
            vim.lsp.util.jump_to_location({uri = uri, range = range}, 'utf-8', true)
          end
          
          -- Close preview window after a short delay
          vim.defer_fn(function()
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_close(win, true)
            end
          end, 5000)  -- 5 second preview
        end
      end)
    end, opts)
  end,
})

-- Setup autocompletion
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
}

-- Set up autopairs
require('nvim-autopairs').setup {}

-- Set up comment plugin
require('Comment').setup {}

-- Set up git signs
require('gitsigns').setup {
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged_enable = true,
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end)

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk)
    map('n', '<leader>hr', gitsigns.reset_hunk)

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('v', '<leader>hr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('n', '<leader>hS', gitsigns.stage_buffer)
    map('n', '<leader>hR', gitsigns.reset_buffer)
    map('n', '<leader>hp', gitsigns.preview_hunk)
    map('n', '<leader>hi', gitsigns.preview_hunk_inline)

    map('n', '<leader>hb', function()
      gitsigns.blame_line({ full = true })
    end)

    map('n', '<leader>hd', gitsigns.diffthis)

    map('n', '<leader>hD', function()
      gitsigns.diffthis('~')
    end)

    map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
    map('n', '<leader>hq', gitsigns.setqflist)

    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
    map('n', '<leader>tw', gitsigns.toggle_word_diff)

    -- Text object
    map({'o', 'x'}, 'ih', gitsigns.select_hunk)
  end
}

-- Set up indent guides
require('ibl').setup {
  indent = { char = "┊" },
  scope = { enabled = true },
}

-- Telescope setup
local telescope = require('telescope')
telescope.setup {}

-- Key mappings
-- General
vim.keymap.set('n', '<leader>w', '<cmd>write<CR>', { desc = 'Save' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to window below' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to window above' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Buffer navigation
vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })

-- File explorer
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })

-- Telescope
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { desc = 'Find help tags' })

-- VSCode-like keybindings (basic ones that don't require additional plugins)
vim.keymap.set('n', '<F1>', '<cmd>help<CR>', { desc = 'Show help' })
vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<CR>', { desc = 'Quick Open (Ctrl+P in VSCode)' })

-- Escpace terminal insert mode with ESC
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })

-- Open terminal like in VScode using :T command
vim.api.nvim_create_user_command('T', function(opts)
  vim.cmd('split')
  vim.cmd('wincmd j')
  vim.cmd('resize 20')
  vim.cmd('terminal ' .. table.concat(opts.fargs, ' '))
end, { nargs = '*' })

-- Allways open terminal in insert mode
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  command = "startinsert"
})

-- Auto commands
-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local line = vim.fn.line
    local last_pos = line("'\"")
    if last_pos > 0 and last_pos <= line("$") then
      vim.api.nvim_win_set_cursor(0, {last_pos, 0})
    end
  end,
})

-- Language-specific settings
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

