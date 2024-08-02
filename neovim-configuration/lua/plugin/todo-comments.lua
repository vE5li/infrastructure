local opts = {
    keywords = {
        FIX = { icon = "" },
        TODO = { icon = "" },
        HACK = { icon = "" },
        WARN = { icon = "" },
        PERF = { icon = "󰥔" },
        NOTE = { icon = "󰎚" },
        TEST = { icon = "" },
    },
}

local keys = {
    {
        "lT",
        ":TodoTelescope<cr>",
        silent = true,
        desc =
        "Find TODOs"
    },
}


return {
    'folke/todo-comments.nvim',
    dependencies = {
        "nvim-telescope/telescope.nvim",
        'nvim-lua/plenary.nvim',
    },
    config = true,
    opts = opts,
    keys = keys,
    event = { "BufRead", "BufNewFile" },
}
