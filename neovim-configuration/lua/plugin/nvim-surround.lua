local opts = {
        keymaps = {
        normal = "<leader>ys",
        normal_cur = "<leader>yss",
        normal_line = "<leader>yS",
        normal_cur_line = "<leader>ySS",
        visual = "<leader>S",
        visual_line = "<leader>gS",
        delete = "<leader>ds",
        change = "<leader>cs",
        change_line = "<leader>cS",
    },
}

return {
    'kylechui/nvim-surround',
    config = true,
    opts = opts,
    event = { "BufRead", "BufNewFile" },
}
