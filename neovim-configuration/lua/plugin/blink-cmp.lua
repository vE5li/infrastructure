local opts = {
    keymap = {
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-l>'] = { 'select_prev', 'fallback' },
        ['<C-e>'] = { 'select_and_accept' },
        ['<C-h>'] = { 'show', 'show_documentation', 'hide_documentation' },
    },

    completion = {
        menu = {
            draw = {
                -- We don't need label_description now because label and label_description are already
                -- combined together in label by colorful-menu.nvim.
                columns = { { "kind_icon" }, { "label", gap = 1 } },
                components = {
                    label = {
                        text = function(ctx)
                            return require("colorful-menu").blink_components_text(ctx)
                        end,
                        highlight = function(ctx)
                            return require("colorful-menu").blink_components_highlight(ctx)
                        end,
                    },
                },
            },
        },
    },

    sources = {
        default = { 'lsp', 'path', 'buffer', 'ripgrep', 'emoji', },
        providers = {
            -- Emoji provider
            emoji = {
                module = "blink-emoji",
                name = "Emoji",
                score_offset = 15,
                should_show_items = function()
                    return vim.tbl_contains(
                        { "gitcommit", "markdown" },
                        vim.o.filetype
                    )
                end,
            },
            -- Ripgrep provider
            ripgrep = {
                module = "blink-ripgrep",
                name = "Ripgrep",
                score_offset = -10,
                ---@module "blink-ripgrep"
                ---@type blink-ripgrep.Options
                opts = {
                    backend = {
                        ripgrep = {
                            project_root_fallback = false,
                        },
                    },
                },
            },
        }
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
    signature = { enabled = true }
}

return {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = {
        'rafamadriz/friendly-snippets',
        "moyiz/blink-emoji.nvim",
        "mikavilpas/blink-ripgrep.nvim",
    },
    version = '1.*',
    build = 'nix run .#build-plugin --accept-flake-config',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = opts,
    opts_extend = { "sources.default" }
}
