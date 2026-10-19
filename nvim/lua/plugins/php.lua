return {
    {
        "jwalton512/vim-blade",
        ft = "blade",
        init = function() vim.filetype.add({ pattern = { [".*%.blade%.php"] = "blade" } }) end,
    },

    {
        "danymat/neogen",
        cmd = "Neogen",
        keys = {
            { "<leader>cg", function() require("neogen").generate() end, desc = "Generate docblock" },
        },
        opts = {
            snippet_engine = "luasnip",
            languages = { php = { template = { annotation_convention = "phpdoc" } } },
        },
    },
}
