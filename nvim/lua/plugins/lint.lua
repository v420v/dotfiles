return {
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                php = { "mago_lint" },
            }

            -- Prefer the project's composer-installed mago, like pint in conform
            lint.linters.mago_lint.cmd = function()
                local local_bin = vim.fs.find("vendor/bin/mago", { upward = true, path = vim.fn.expand("%:p:h") })[1]
                return local_bin or "mago"
            end

            -- mago reads the file from disk, so lint on open and after saving
            vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
                group = vim.api.nvim_create_augroup("UserLint", { clear = true }),
                callback = function() lint.try_lint() end,
            })

            vim.keymap.set("n", "<leader>ck", function() lint.try_lint() end, { desc = "Lint buffer" })
        end,
    },
}
