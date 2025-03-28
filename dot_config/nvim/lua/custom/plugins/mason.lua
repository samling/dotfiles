return {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
        "williamboman/mason.nvim",
        "neovim/nvim-lspconfig",
    },
    build = ":MasonUpdate",
    -- cmd = { "Mason", "MasonLog" },
    -- event = { "VeryLazy" },
    -- lazy = true,
    config = function()
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        mason_lspconfig.setup({
            lazy = true,
            automatic_installation = true,
            ensure_installed = {
                "arduino_language_server",
                "awk_ls",
                "clangd",
                "cssls",
                "gopls",
                "html",
                "jdtls",
                "lua_ls",
                "rust_analyzer",
                "tailwindcss",

            },
        })
    end,
}
