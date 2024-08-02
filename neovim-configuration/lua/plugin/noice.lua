local opts = {
    cmdline = {
        view = "cmdline_popup",
        format = {
            cmdline = { icon = ":" },
            search_up = { icon = "?" },
            search_down = { icon = "/" },
        }
    },
    messages = {
        view = "mini",
        view_error = "mini",
        view_warn = "mini",
    },
    views = {
        mini = {
            timeout = 8000,
        },
        popup = {
            border = {
                style = "none",
            },
        },
        -- cmdline_popup = {
        --     border = {
        --         style = "none",
        --     },
        -- },
        confirm = {
            border = {
                style = "none",
            },
        },
        presets = {
            long_message_to_split = true,
        }
    },
    routes = {
        {
            filter = {
                event = 'msg_show',
                kind = '',
                find = '; before ',
            },
            opts = { skip = true },
        },
        {
            filter = {
                event = 'msg_show',
                kind = '',
                find = '; after ',
            },
            opts = { skip = true },
        },
        {
            filter = {
                event = 'msg_show',
                kind = '',
                find = 'Already at newest change',
            },
            opts = { skip = true },
        },
        {
            filter = {
                event = 'msg_show',
                kind = '',
                find = 'Already at oldest change',
            },
            opts = { skip = true },
        },
    },
}

return {
    "folke/noice.nvim",
    dependencies = { 'nvim-treesitter/nvim-treesitter', "MunifTanjim/nui.nvim" },
    opts = opts,
    event = "VeryLazy",
}
