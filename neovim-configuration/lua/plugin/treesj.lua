local opts = {
    use_default_keymaps = false,
}

local keys = {
    { "<leader>rs", function() package.loaded.treesj.split() end, desc = "Split node" },
    { "<leader>rj", function() package.loaded.treesj.join() end, desc = "Join node" },
}

return {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = true,
    opts = opts,
    keys = keys,
}
