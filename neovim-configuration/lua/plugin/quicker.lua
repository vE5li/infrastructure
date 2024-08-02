---@module "quicker"
---@type quicker.SetupOptions
local opts = {
    constrain_cursor = false,
}

local keys = {
    {
        ">",
        function()
            require("quicker").expand({ before = 4, after = 4, add_to_existing = true })
        end,
        desc = "Expand quickfix context",
    },
    {
        "<",
        function()
            require("quicker").collapse()
        end,
        desc = "Collapse quickfix context",
    },
    {
        "gq",
        ":.cc<cr>",
        desc = "Go to quickfix entry",
    },
}

return {
    'stevearc/quicker.nvim',
    event = "FileType qf",
    opts = opts,
    keys = keys,
}
