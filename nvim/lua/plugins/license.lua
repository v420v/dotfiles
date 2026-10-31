return {
    -- package.json / Cargo.toml / go.mod などの依存行の行末に、
    -- そのパッケージのライセンスを virtual text で表示する。
    -- 本体は同梱の Node 製 LSP サーバーで、build で packages/lsp-server/dist/lspServer.js を生成する（Node 22 以上が必要）
    {
        "otnc/package-license-viewer",
        build = "npm install --no-audit --no-fund && npm run compile:lsp",
        event = {
            {
                event = { "BufReadPost", "BufNewFile" },
                pattern = {
                    "*.json",
                    "*.jsonc",
                    "Cargo.toml",
                    "pnpm-workspace.yaml",
                    "pnpm-workspace.yml",
                    "moon.mod",
                    "go.mod",
                },
            },
        },
        cmd = { "PackageLicenseViewerToggle", "PackageLicenseViewerRefresh", "PackageLicenseViewerClearCache" },
        keys = {
            { "<leader>ul", "<cmd>PackageLicenseViewerToggle<CR>", desc = "Toggle package license annotations" },
        },
        config = function(plugin)
            -- Neovim 用の plugin/ と lua/ はリポジトリ直下ではなく packages/vim-plugin にある。
            -- lazy.nvim はサブディレクトリを rtp に加えられないので、ここで足してから plugin/ を読む
            vim.opt.rtp:append(plugin.dir .. "/packages/vim-plugin")
            vim.cmd("runtime! plugin/package_license_viewer.vim")

            -- virtual text のハイライトは plugin 側で "Comment" / "String" が直書きされていて、
            -- ライセンス名だけ String で明るく表示される。専用のハイライトグループが無いので、
            -- この plugin の namespace 宛ての extmark だけ String を Comment に差し替えて全体をコメント色に揃える
            local ns = vim.api.nvim_create_namespace("package_license_viewer")
            local set_extmark = vim.api.nvim_buf_set_extmark
            vim.api.nvim_buf_set_extmark = function(bufnr, ns_id, line, col, opts)
                if ns_id == ns and opts and opts.virt_text then
                    for _, chunk in ipairs(opts.virt_text) do
                        if chunk[2] == "String" then
                            chunk[2] = "Comment"
                        end
                    end
                end
                return set_extmark(bufnr, ns_id, line, col, opts)
            end
        end,
    },
}
