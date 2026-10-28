-- マルチカーソル: jake-stewart/multicursor.nvim
-- VSCode の Cmd-d 相当が <C-n>、Cmd-Shift-L 相当が <leader>ma。
-- 複数カーソルがある間だけ有効なキー（<Esc> で解除など）は addKeymapLayer で定義。
return {
    {
        "jake-stewart/multicursor.nvim",
        branch = "1.0",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local mc = require("multicursor-nvim")
            mc.setup()

            local set = vim.keymap.set
            local nx = { "n", "x" }

            -- 単語 / 選択範囲に一致する次の箇所にカーソルを追加（VSCode: Cmd-d）
            set(nx, "<C-n>", function() mc.matchAddCursor(1) end, { desc = "MC: add cursor at next match" })
            set(nx, "<leader>mn", function() mc.matchAddCursor(1) end, { desc = "Add cursor at next match" })
            set(nx, "<leader>mN", function() mc.matchAddCursor(-1) end, { desc = "Add cursor at prev match" })
            set(nx, "<leader>ms", function() mc.matchSkipCursor(1) end, { desc = "Skip next match" })
            set(nx, "<leader>mS", function() mc.matchSkipCursor(-1) end, { desc = "Skip prev match" })
            set(nx, "<leader>ma", mc.matchAllAddCursors, { desc = "Add cursors at all matches" })

            -- 上下の行にカーソルを追加（VSCode: Cmd-Alt-Up/Down）
            set(nx, "<leader>mk", function() mc.lineAddCursor(-1) end, { desc = "Add cursor above" })
            set(nx, "<leader>mj", function() mc.lineAddCursor(1) end, { desc = "Add cursor below" })
            set(nx, "<leader>mK", function() mc.lineSkipCursor(-1) end, { desc = "Skip line above" })
            set(nx, "<leader>mJ", function() mc.lineSkipCursor(1) end, { desc = "Skip line below" })

            -- 直前の / 検索の一致にカーソルを追加
            set("n", "<leader>m/", function() mc.searchAddCursor(1) end, { desc = "Add cursor at next search match" })
            set("n", "<leader>m?", mc.searchAllAddCursors, { desc = "Add cursors at all search matches" })

            -- ビジュアル選択を加工
            set("x", "<leader>mv", mc.visualToCursors, { desc = "Visual: cursor per line" })
            set("x", "<leader>mm", mc.matchCursors, { desc = "Visual: cursors at regex matches" })
            set("x", "<leader>mx", mc.splitCursors, { desc = "Visual: split by regex" })
            set("x", "I", mc.insertVisual, { desc = "Insert at start of each line" })
            set("x", "A", mc.appendVisual, { desc = "Append at end of each line" })

            -- その他
            set(nx, "<leader>mo", mc.operator, { desc = "Add cursors with motion (e.g. <leader>moiw)" })
            set("n", "<leader>mA", mc.alignCursors, { desc = "Align cursors" })
            set(nx, "<leader>mt", mc.toggleCursor, { desc = "Toggle cursors on/off" })
            set("n", "<leader>mr", mc.restoreCursors, { desc = "Restore last cursors" })
            set(nx, "g<C-a>", mc.sequenceIncrement, { desc = "Increment as sequence" })
            set(nx, "g<C-x>", mc.sequenceDecrement, { desc = "Decrement as sequence" })

            -- Ctrl+クリックでカーソルを追加 / 削除（Cmd+クリックは定義ジャンプなので衝突しない）
            set("n", "<C-LeftMouse>", mc.handleMouse)
            set("n", "<C-LeftDrag>", mc.handleMouseDrag)
            set("n", "<C-LeftRelease>", mc.handleMouseRelease)

            -- 複数カーソルがあるときだけ有効なキー
            mc.addKeymapLayer(function(layer)
                layer(nx, "<Left>", mc.prevCursor, { desc = "Prev cursor" })
                layer(nx, "<Right>", mc.nextCursor, { desc = "Next cursor" })
                layer(nx, "<leader>md", mc.deleteCursor, { desc = "Delete main cursor" })
                layer("n", "<Esc>", function()
                    if not mc.cursorsEnabled() then
                        mc.enableCursors()
                    else
                        mc.clearCursors()
                    end
                end, { desc = "Clear cursors" })
            end)

            local function paint()
                local hl = vim.api.nvim_set_hl
                hl(0, "MultiCursorCursor", { reverse = true })
                hl(0, "MultiCursorVisual", { link = "Visual" })
                hl(0, "MultiCursorSign", { link = "SignColumn" })
                hl(0, "MultiCursorMatchPreview", { link = "Search" })
                hl(0, "MultiCursorDisabledCursor", { reverse = true })
                hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
                hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
            end
            paint()
            vim.api.nvim_create_autocmd("ColorScheme", { callback = paint })
        end,
    },
}
