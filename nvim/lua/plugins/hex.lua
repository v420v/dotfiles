return {
    {
        "RaafatTurki/hex.nvim",
        cmd = { "HexToggle", "HexDump", "HexAssemble" },
        keys = {
            { "<leader>xx", "<cmd>HexToggle<CR>", desc = "Hex: toggle dump" },
            { "<leader>xd", "<cmd>HexDump<CR>", desc = "Hex: dump (bin → xxd)" },
            { "<leader>xa", "<cmd>HexAssemble<CR>", desc = "Hex: assemble (xxd → bin)" },
        },
        opts = {},
        config = function(_, opts)
            require("hex").setup(opts)
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
