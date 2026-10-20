return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        keys = {
            { "<leader>um", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown render" },
        },
        opts = {},
    },
}
