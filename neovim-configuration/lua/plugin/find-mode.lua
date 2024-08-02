---@module "find-mode"
---@type find-mode.Options
local opts = {
}

local keys = {
    { "g/", function() require("find-mode").enter_find_mode() end, desc = "Enter find mode" },
}

return {
    "ve5li/find-mode.nvim",
    config = true,
    opts = opts,
    keys = keys,
}
