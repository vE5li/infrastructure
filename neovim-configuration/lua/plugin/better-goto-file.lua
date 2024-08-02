---@module "better-goto-file"
---@type better-goto-file.Options
local opts = {
    message_on_error = false,
}

local keys = {
    { "<leader>f",      mode = { "n" }, function() require("better-goto-file").goto_file() end,                                  silent = true, desc = "Better go to file under cursor" },
    { "<leader>f",      mode = { "v" }, '<Esc>:lua require("better-goto-file").goto_file_range()<cr>',                           silent = true, desc = "Better go to file in selection" },
    -- Open in new split.
    { "<C-w><leader>f", mode = { "n" }, function() require("better-goto-file").goto_file({ gf_command = "<C-w>f" }) end,         silent = true, desc = "Better go to file under cursor in new split" },
    { "<C-w><leader>f", mode = { "v" }, '<Esc>:lua require("better-goto-file").goto_file_range({ gf_command = "<C-w>f" })<cr>',  silent = true, desc = "Better go to file in selection in new split" },
    -- Open in new tab.
    { "<C-w><leader>F", mode = { "n" }, function() require("better-goto-file").goto_file({ gf_command = "<C-w>gf" }) end,        silent = true, desc = "Better go to file under cursor in new tab" },
    { "<C-w><leader>F", mode = { "v" }, '<Esc>:lua require("better-goto-file").goto_file_range({ gf_command = "<C-w>gf" })<cr>', silent = true, desc = "Better go to file in selection in new tab" },
}

return {
    "ve5li/better-goto-file.nvim",
    config = true,
    opts = opts,
    keys = keys,
}
