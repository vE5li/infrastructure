return {
    "OXY2DEV/markview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = true,
    -- See readme on GitHub for why this plugin should not be lazy loaded.
    lazy = false,
    -- HACK: To avoid loading this plugin before nvim-treesitter.
    priority = 49,
}
