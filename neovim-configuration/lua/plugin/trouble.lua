local keys = {
    { "lp", ":TroubleToggle<cr>", silent = true, desc = "Toggle diagnostics window" }
}

return {
    'folke/trouble.nvim',
    dependencies = 'kyazdani42/nvim-web-devicons',
    config = true,
    keys = keys,
    cmd = "TodoTrouble",
}
