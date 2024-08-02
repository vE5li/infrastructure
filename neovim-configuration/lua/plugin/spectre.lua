local keys = {
    { 'se', function() package.loaded.spectre.toggle() end, desc = "Search and replace in working directory" },
    {
        'se',
        function() package.loaded.spectre.open_visual() end,
        mode = 'v',
        desc =
        "Substitute everywhere"
    },
}

local opts = {
    live_update = true,

    mapping = {
        ['send_to_qf'] = {
            map = "gq",
            cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
            desc = "send all items to quickfix"
        },
        ['replace_cmd'] = {
            map = "gc",
            cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
            desc = "input replace command"
        },
        ['show_option_menu'] = {
            map = "go",
            cmd = "<cmd>lua require('spectre').show_options()<CR>",
            desc = "show options"
        },
        ['run_current_replace'] = {
            map = "grc",
            cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
            desc = "replace current line"
        },
        ['run_replace'] = {
            map = "gR",
            cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
            desc = "replace all"
        },
        ['change_view_mode'] = {
            map = "gv",
            cmd = "<cmd>lua require('spectre').change_view()<CR>",
            desc = "change result view mode"
        },
        ['resume_last_search'] = {
            map = "gl",
            cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
            desc = "repeat last search"
        },
    },
}

return {
    'nvim-pack/nvim-spectre',
    dependencies = 'nvim-lua/plenary.nvim',
    config = true,
    opts = opts,
    keys = keys,
}
