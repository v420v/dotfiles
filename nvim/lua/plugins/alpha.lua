-- ─── Alpha dashboard ──── Catppuccin Mocha rice ──────────────
return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "MaximilianLloyd/ascii.nvim",
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local alpha     = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- ── Header ── ascii.nvim "sharp" Neovim logo
        dashboard.section.header.val     = require("ascii").art.text.neovim.sharp
        dashboard.section.header.opts.hl = "AlphaHeader"

        -- ── Buttons ──
        local function button(sc, icon, label, cmd)
            local b = dashboard.button(sc, icon .. "  " .. label, cmd)
            b.opts.hl          = "AlphaButton"
            b.opts.hl_shortcut = "AlphaShortcut"
            b.opts.shortcut    = sc
            b.opts.position    = "center"
            b.opts.cursor      = 3
            b.opts.width       = 40
            b.opts.align_shortcut = "right"
            return b
        end

        dashboard.section.buttons.val = {
            button("o", "", "Oil",           "<cmd>lua require('oil').open(vim.fn.getcwd())<CR>"),
            button("f", "", "Find file",     "<cmd>Telescope find_files<CR>"),
            button("i", "", "New file",      "<cmd>enew | startinsert<CR>"),
            button("t", "", "Edit temp file","<cmd>lua vim.cmd('edit '..vim.fn.tempname())<CR>"),
            button("r", "", "Recent files", "<cmd>Telescope oldfiles<CR>"),
            button("g", "", "Find text",     "<cmd>Telescope live_grep<CR>"),
            button("l", "󰒲", "Lazy",          "<cmd>Lazy<CR>"),
            button("h", "", "Check health", "<cmd>checkhealth<CR>"),
            button("q", "", "Quit",          "<cmd>qa<CR>"),
        }
        dashboard.section.buttons.opts.spacing = 1

        -- ── Footer ── date · time · plugin count · nvim version
        local function footer()
            local v       = vim.version()
            local version = string.format("v%d.%d.%d", v.major, v.minor, v.patch)
            local count   = require("lazy").stats().count
            return string.format(
                " %s    %s   %d plugins    %s",
                os.date("%Y-%m-%d"),
                os.date("%H:%M:%S"),
                count,
                version
            )
        end

        dashboard.section.footer.val     = footer()
        dashboard.section.footer.opts.hl = "AlphaFooter"

        -- ── Layout ──
        dashboard.opts.layout = {
            { type = "padding", val = 2 },
            dashboard.section.header,
            { type = "padding", val = 3 },
            dashboard.section.buttons,
            { type = "padding", val = 1 },
            dashboard.section.footer,
        }

        -- ── Highlights (Catppuccin Mocha) ──
        local function paint()
            vim.api.nvim_set_hl(0, "AlphaHeader",   { fg = "#89b4fa", bold = true })  -- blue
            vim.api.nvim_set_hl(0, "AlphaButton",   { fg = "#cdd6f4" })                -- text
            vim.api.nvim_set_hl(0, "AlphaShortcut",{ fg = "#89b4fa", italic = true })  -- blue italic
            vim.api.nvim_set_hl(0, "AlphaFooter",   { fg = "#fab387" })                -- peach
        end
        paint()
        vim.api.nvim_create_autocmd("ColorScheme", { callback = paint })

        alpha.setup(dashboard.opts)

        -- Refresh the footer once lazy.nvim is fully done loading.
        vim.api.nvim_create_autocmd("User", {
            once    = true,
            pattern = "VeryLazy",
            callback = function()
                dashboard.section.footer.val = footer()
                pcall(vim.cmd.AlphaRedraw)
            end,
        })

        -- A live clock looks better than a frozen timestamp.
        local timer = (vim.uv or vim.loop).new_timer()
        timer:start(0, 1000, vim.schedule_wrap(function()
            if vim.bo.filetype ~= "alpha" then return end
            dashboard.section.footer.val = footer()
            pcall(vim.cmd.AlphaRedraw)
        end))

        -- Hide cursor / end-of-buffer tildes on the dashboard.
        vim.api.nvim_create_autocmd("FileType", {
            pattern  = "alpha",
            callback = function()
                vim.opt_local.cursorline = false
                vim.opt_local.fillchars  = { eob = " " }
            end,
        })
    end,
}
