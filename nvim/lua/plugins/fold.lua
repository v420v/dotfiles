-- フォールド: treesitter ベース + nvim-ufo（折りたたみ行のプレビュー・行数表示）
-- ガターの折りたたみアイコンは statuscol.nvim（左から: fold / sign / 行番号）
return {
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = { "BufReadPost", "BufNewFile" },
        keys = {
            { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
            { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
            { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "Open folds (one level)" },
            { "zm", function() require("ufo").closeFoldsWith() end, desc = "Close folds (one level)" },
            {
                "z1",
                function() require("ufo").closeFoldsWith(0) end,
                desc = "Fold to level 1",
            },
            {
                "z2",
                function() require("ufo").closeFoldsWith(1) end,
                desc = "Fold to level 2",
            },
            {
                "z3",
                function() require("ufo").closeFoldsWith(2) end,
                desc = "Fold to level 3",
            },
            {
                "zK",
                function()
                    local winid = require("ufo").peekFoldedLinesUnderCursor()
                    if not winid then vim.lsp.buf.hover() end
                end,
                desc = "Peek folded lines (or hover)",
            },
        },
        init = function()
            vim.o.foldcolumn = "1"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
            vim.opt.fillchars:append({
                -- VSCode / Zed と同じ codicon のシェブロン
                foldopen = "\u{EAB4}", -- nf-cod-chevron_down
                foldclose = "\u{EAB6}", -- nf-cod-chevron_right
                fold = " ",
                foldsep = " ",
            })
        end,
        opts = {
            provider_selector = function() return { "treesitter", "indent" } end,
            open_fold_hl_timeout = 150,
            close_fold_kinds_for_ft = { default = { "imports", "comment" } },
            preview = {
                win_config = { border = "rounded", winblend = 0, winhighlight = "Normal:Normal" },
                mappings = { scrollU = "<C-u>", scrollD = "<C-d>", jumpTop = "[", jumpBot = "]" },
            },
            -- 折りたたみ行の末尾に「 󰁂 12 lines」を付ける
            fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate)
                local result = {}
                local suffix = ("  󰁂 %d lines"):format(end_lnum - lnum)
                local suf_width = vim.fn.strdisplaywidth(suffix)
                local target = width - suf_width
                local cur = 0
                for _, chunk in ipairs(virt_text) do
                    local text = chunk[1]
                    local w = vim.fn.strdisplaywidth(text)
                    if target > cur + w then
                        table.insert(result, chunk)
                    else
                        text = truncate(text, target - cur)
                        table.insert(result, { text, chunk[2] })
                        w = vim.fn.strdisplaywidth(text)
                        if cur + w < target then suffix = suffix .. (" "):rep(target - cur - w) end
                        break
                    end
                    cur = cur + w
                end
                table.insert(result, { suffix, "UfoFoldedEllipsis" })
                return result
            end,
        },
    },

    {
        "luukvbaal/statuscol.nvim",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local builtin = require("statuscol.builtin")
            require("statuscol").setup({
                relculright = true,
                ft_ignore = { "snacks_picker_list", "snacks_terminal", "alpha", "help", "lazy", "qf" },
                bt_ignore = { "terminal", "nofile", "prompt" },
                segments = {
                    -- fold アイコンと gitsigns の間に 1 桁の余白を入れる
                    { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
                    { text = { "%s" }, click = "v:lua.ScSa" },
                    { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
                },
            })
        end,
    },
}
