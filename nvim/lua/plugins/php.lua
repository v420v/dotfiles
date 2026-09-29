return {
    {
        "jwalton512/vim-blade",
        ft = "blade",
        init = function() vim.filetype.add({ pattern = { [".*%.blade%.php"] = "blade" } }) end,
    },
}
