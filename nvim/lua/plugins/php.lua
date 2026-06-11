-- ─── PHP / Laravel ───────────────────────────────────────────
-- The PHP language server (intelephense), formatter (Pint / php-cs-fixer)
-- and treesitter grammars are wired up in lsp.lua and treesitter.lua.
-- This file covers the Laravel-specific bits that live outside those:
-- Blade template support.
return {
    -- Blade syntax + indent for *.blade.php. intelephense/treesitter only
    -- understand plain PHP, so Blade's `@directive` / `{{ }}` templating gets
    -- this lightweight vim-regex highlighter instead (no compiler needed,
    -- unlike a treesitter grammar — matters on Nix hosts without a C
    -- toolchain on PATH).
    {
        "jwalton512/vim-blade",
        ft = "blade",
        -- Register the filetype ourselves so lazy's `ft` trigger fires before
        -- the plugin (whose own ftdetect would otherwise never get a chance
        -- to load) is needed.
        init = function()
            vim.filetype.add({ pattern = { [".*%.blade%.php"] = "blade" } })
        end,
    },
}
