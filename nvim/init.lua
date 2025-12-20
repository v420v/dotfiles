
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
vim.opt.winblend = 0
vim.opt.pumblend = 0


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

  -- Theme
  use({
    'projekt0n/github-nvim-theme',
    config = function()
      require('github-theme').setup({
        -- ...
      })
      vim.cmd('colorscheme github_dark')
    end
  })

  -- Status line
  use {
    'nvim-lualine/lualine.nvim',
    'kyazdani42/nvim-web-devicons',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  use {
    'goolord/alpha-nvim',
    config = function ()
        require'alpha'.setup(require'alpha.themes.dashboard'.config)
    end
  }

  -- File explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  -- Buffer tabs
  use {'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons'}

  -- Fuzzy finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Advanced search and replace
  use {
    'nvim-pack/nvim-spectre',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Syntax Highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- Indent guides
  use 'lukas-reineke/indent-blankline.nvim'

  -- Git signs (show git changes in line numbers)
  use 'lewis6991/gitsigns.nvim'

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
end)


-----------------------
-- Theme
-----------------------
vim.cmd('colorscheme github_dark')


-----------------------
-- Window navigation
-----------------------
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to window below' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to window above' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })


-----------------------
-- Treesitter
-----------------------
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "lua", "go", "php", "javascript", "typescript",
    "html", "css", "json", "yaml"
  },
  highlight = {
    enable = true,
  },
}


-----------------------
-- Status line setup
-----------------------
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


-----------------------
-- File explorer setup
-----------------------
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
    highlight_git = true, -- ← enable highlighting for git status
    icons = {
      show = {
        git = true,      -- ← git icons
      },
      glyphs = {
        git = {
          unstaged  = "✗",
          staged    = "✓",
          unmerged  = "",
          renamed   = "➜",
          untracked = "★",
          deleted   = "",
          ignored   = "◌",
        },
      },
    },
  },
}
-- File explorer
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })


-----------------------
-- Buffer line setup
-----------------------
require('bufferline').setup {
  options = {
    separator_style = "thin",
  }
}


-- Buffer (tab) navigation
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bl', ':bnext<CR>', { desc = 'Next buffer (left)' })
vim.keymap.set('n', '<leader>bh', ':bprevious<CR>', { desc = 'Previous buffer (right)' })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Delete buffer' })
vim.keymap.set('n', '<leader>bD', ':bdelete!<CR>', { desc = 'Force delete buffer' })

-- Terminal mode escape
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })


-----------------------
-- Set up indent guides
-----------------------
require('ibl').setup {
  indent = { char = "┊" },
  scope = { enabled = true },
}


-----------------------
-- Git signs setup
-----------------------
require('gitsigns').setup {
  signs = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
}


-- Git signs key mappings
vim.keymap.set('n', '<leader>gh', ':Gitsigns preview_hunk<CR>', { desc = 'Preview hunk diff' })
vim.keymap.set('n', '<leader>gd', ':Gitsigns diffthis<CR>', { desc = 'Toggle diff for current file' })
vim.keymap.set('n', '<leader>gD', ':Gitsigns diffthis ~<CR>', { desc = 'Toggle diff against HEAD' })
vim.keymap.set('n', ']h', ':Gitsigns next_hunk<CR>', { desc = 'Next hunk' })
vim.keymap.set('n', '[h', ':Gitsigns prev_hunk<CR>', { desc = 'Previous hunk' })
vim.keymap.set('n', '<leader>gs', ':Gitsigns stage_hunk<CR>', { desc = 'Stage hunk' })
vim.keymap.set('n', '<leader>gu', ':Gitsigns undo_stage_hunk<CR>', { desc = 'Undo stage hunk' })
vim.keymap.set('n', '<leader>gr', ':Gitsigns reset_hunk<CR>', { desc = 'Reset hunk' })
vim.keymap.set('n', '<leader>gR', ':Gitsigns reset_buffer<CR>', { desc = 'Reset buffer' })
vim.keymap.set('n', '<leader>gb', ':Gitsigns toggle_current_line_blame<CR>', { desc = 'Toggle line blame' })
vim.keymap.set('n', '<leader>gt', ':Gitsigns toggle_deleted<CR>', { desc = 'Toggle deleted lines' })


-----------------------
-- Telescope setup
-----------------------
local telescope = require('telescope')
telescope.setup {}
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { desc = 'Find help tags' })


-----------------------
-- Advanced Search and Replace (nvim-spectre)
-----------------------
require('spectre').setup {
  mapping = {
    ['toggle_line'] = {
      map = "dd",
      cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
      desc = "toggle current item"
    },
    ['enter_file'] = {
      map = "<cr>",
      cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
      desc = "goto current file"
    },
    ['send_to_qf'] = {
      map = "<leader>q",
      cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
      desc = "send all item to quickfix"
    },
    ['replace_cmd'] = {
      map = "<leader>r",
      cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
      desc = "input replace vim command"
    },
    ['show_option_menu'] = {
      map = "<leader>o",
      cmd = "<cmd>lua require('spectre').show_options()<CR>",
      desc = "show option"
    },
    ['run_replace'] = {
      map = "<leader>R",
      cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
      desc = "replace all"
    },
    ['change_view_mode'] = {
      map = "<leader>v",
      cmd = "<cmd>lua require('spectre').change_view()<CR>",
      desc = "change result view mode"
    },
    ['toggle_live_update'] = {
      map = "tu",
      cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
      desc = "update change when vim write file."
    },
    ['toggle_ignore_case'] = {
      map = "ti",
      cmd = "<cmd>lua require('spectre').show_options()<CR>",
      desc = "show options menu (use to toggle ignore case)"
    },
    ['toggle_ignore_hidden'] = {
      map = "th",
      cmd = "<cmd>lua require('spectre').toggle_ignore_hidden()<CR>",
      desc = "toggle search hidden"
    },
    ['toggle_match_word'] = {
      map = "tw",
      cmd = "<cmd>lua require('spectre').show_options()<CR>",
      desc = "show options menu (use to toggle match word)"
    },
    ['resume_last_search'] = {
      map = "<leader>l",
      cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
      desc = "resume last search"
    },
  }
}

-- Key mappings for search and replace
vim.keymap.set('n', '<leader>sr', function()
  require('spectre').open()
end, { desc = 'Search and replace' })

vim.keymap.set('n', '<leader>sw', function()
  require('spectre').open_visual({ select_word = true })
end, { desc = 'Search current word' })

vim.keymap.set('v', '<leader>sw', function()
  require('spectre').open_visual()
end, { desc = 'Search selected text' })


-----------------------
-- Language specific settings
-----------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "css",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-----------------------
-- LSP (Language Server Protocol) setup
-----------------------
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
-- LSP共通設定
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- LSPキーマッピング（LspAttachイベントで設定）
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(args)
    local bufnr = args.buf
    local opts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set('n', 'jD', vim.lsp.buf.declaration, vim.tbl_extend('force', opts, { desc = 'Go to declaration' }))
    vim.keymap.set('n', 'jd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover' }))
    vim.keymap.set('n', 'ji', vim.lsp.buf.implementation, vim.tbl_extend('force', opts, { desc = 'Go to implementation' }))
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, vim.tbl_extend('force', opts, { desc = 'Signature help' }))
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, vim.tbl_extend('force', opts, { desc = 'Add workspace folder' }))
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, vim.tbl_extend('force', opts, { desc = 'Remove workspace folder' }))
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, vim.tbl_extend('force', opts, { desc = 'List workspace folders' }))
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, vim.tbl_extend('force', opts, { desc = 'Type definition' }))
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'Rename' }))
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'Code action' }))
    vim.keymap.set('n', 'jr', vim.lsp.buf.references, vim.tbl_extend('force', opts, { desc = 'References' }))
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, vim.tbl_extend('force', opts, { desc = 'Format' }))
  end,
})

-- Mason LSP設定
local mason_registry = require('mason-registry')

-- Masonでインストールされたサーバーのコマンドパスを取得するヘルパー関数
local function get_mason_cmd(server_name)
  local package = mason_registry.get_package(server_name)
  if package and package:is_installed() then
    local install_path = package:get_install_path()
    -- サーバー名に応じて適切なコマンドパスを返す
    local cmd_map = {
      intelephense = { install_path .. '/node_modules/.bin/intelephense', '--stdio' },
      gopls = { install_path .. '/bin/gopls' },
      ts_ls = { install_path .. '/node_modules/.bin/typescript-language-server', '--stdio' },
      html = { install_path .. '/node_modules/.bin/vscode-html-language-server', '--stdio' },
      cssls = { install_path .. '/node_modules/.bin/vscode-css-language-server', '--stdio' },
    }
    return cmd_map[server_name]
  end
  return nil
end

require('mason-lspconfig').setup {
  ensure_installed = {
    "intelephense",      -- PHP
    "gopls",             -- Go
    "ts_ls",             -- TypeScript/JavaScript
    "html",              -- HTML
    "cssls",             -- CSS
  },
  automatic_installation = true,
  handlers = {
    -- デフォルトハンドラー（すべてのサーバーに適用）
    function(server_name)
      local config = {
        name = server_name,
        capabilities = capabilities,
      }

      -- Masonでインストールされたサーバーのコマンドパスを取得
      local cmd = get_mason_cmd(server_name)
      if cmd then
        config.cmd = cmd
      end

      vim.lsp.start(config)
    end,
    -- PHP (Intelephense) - カスタム設定
    ['intelephense'] = function()
      local cmd = get_mason_cmd('intelephense') or { 'intelephense', '--stdio' }

      vim.lsp.start({
        name = 'intelephense',
        cmd = cmd,
        capabilities = capabilities,
        settings = {
          intelephense = {
            files = {
              maxSize = 5000000,
            },
          },
        },
      })
    end,
    -- Go (gopls) - カスタム設定
    ['gopls'] = function()
      local cmd = get_mason_cmd('gopls') or { 'gopls' }

      vim.lsp.start({
        name = 'gopls',
        cmd = cmd,
        capabilities = capabilities,
        settings = {
          gopls = {
            gofumpt = true,
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
          },
        },
      })
    end,
    -- TypeScript/JavaScript (ts_ls) - カスタム設定
    ['ts_ls'] = function()
      local cmd = get_mason_cmd('ts_ls') or { 'typescript-language-server', '--stdio' }

      vim.lsp.start({
        name = 'ts_ls',
        cmd = cmd,
        capabilities = capabilities,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })
    end,
    -- HTML - カスタム設定
    ['html'] = function()
      local cmd = get_mason_cmd('html') or { 'vscode-html-language-server', '--stdio' }

      vim.lsp.start({
        name = 'html',
        cmd = cmd,
        capabilities = capabilities,
        filetypes = { 'html', 'htmldjango' },
      })
    end,
    -- CSS - カスタム設定
    ['cssls'] = function()
      local cmd = get_mason_cmd('cssls') or { 'vscode-css-language-server', '--stdio' }

      vim.lsp.start({
        name = 'cssls',
        cmd = cmd,
        capabilities = capabilities,
      })
    end,
  },
}

-- LSP診断の設定
vim.diagnostic.config({
  virtual_text = {
    severity = vim.diagnostic.severity.ERROR,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- 診断アイコンの設定
local signs = { Error = "✗", Warn = "⚠", Hint = "➜", Info = "ℹ" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- 診断キーマッピング
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })


-----------------------
-- Autocompletion (nvim-cmp)
-----------------------
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
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
  }),
})

-- コマンドライン補完
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- LuaSnip設定
require('luasnip.loaders.from_vscode').lazy_load()

