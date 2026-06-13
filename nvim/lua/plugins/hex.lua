-- ─── Hex editor for binaries ─────────────────────────────────
-- Object files, executables and other binary buffers get auto-converted
-- to an `xxd` dump on open and converted back on write. Useful for
-- compiler/assembler output (a.out, *.o, *.elf, *.bin, ...).
return {
    {
        "RaafatTurki/hex.nvim",
        cmd = { "HexToggle", "HexDump", "HexAssemble" },
        keys = {
            { "<leader>xx", "<cmd>HexToggle<CR>",   desc = "Hex: toggle dump" },
            { "<leader>xd", "<cmd>HexDump<CR>",     desc = "Hex: dump (bin → xxd)" },
            { "<leader>xa", "<cmd>HexAssemble<CR>", desc = "Hex: assemble (xxd → bin)" },
        },
        opts = {},
        config = function(_, opts)
            require("hex").setup(opts)
            -- Upstream dump_to_hex pipes the buffer to xxd while ALSO passing
            -- the filename as an argument. xxd reads the file and closes stdin
            -- before nvim finishes writing → EPIPE. Override to read from
            -- stdin only (the buffer already holds the file contents).
            local u = require("hex.utils")
            u.dump_to_hex = function(hex_dump_cmd)
                vim.bo.bin = true
                vim.b.hex = true
                vim.cmd("%! " .. hex_dump_cmd)
                vim.b.hex_ft = vim.bo.ft
                vim.bo.ft = "xxd"
                u.drop_undo_history()
                u.dettach_all_lsp_clients_from_current_buf()
                vim.bo.mod = false
            end
        end,
    },
}
