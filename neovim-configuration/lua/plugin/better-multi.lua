local keys = {
    {
        "<C-e>",
        "<Esc>:MultiVisualMode<cr>",
        mode = "v",
        silent = true,
        desc =
        "Enter visual multi mode"
    },
    { "<C-e>",     "viwo<Esc>:MultiVisualMode<cr>n",           silent = true, desc = "Enter visual multi mode" },
    { "U",         ":MultiAddCursor<cr>:MultiNormalMode<cr>U", silent = true, desc = "Add cursor down" },
    { "E",         ":MultiAddCursor<cr>:MultiNormalMode<cr>E", silent = true, desc = "Add cursor up" },
    { "<leader>m", ":MultiAddCursor<cr>",                      silent = true, desc = "Add cursor below cursor" },
    { "<leader>r", ":MultiRemoveCursors<cr>",                  silent = true, desc = "Remove all multi cursors" },
    { "<leader>e", ":MultiNormalMode<cr>",                     silent = true, desc = "Switch to multi normal mode" },
}

return {
    've5li/better-multi.nvim',
    dependencies = 'nvim-libmodal',
    config = true,
    keys = keys,
}
