local opts = {
    triggers = {},
}

local keys = {
    {
        "<leader>?",
        ":WhichKey<cr>",
        { desc = "Open WhichKey", silent = true },
    },
}

return {
    "folke/which-key.nvim",
    config = true,
    opts = opts,
    keys = keys,
    cmd = 'WhichKey',
}
