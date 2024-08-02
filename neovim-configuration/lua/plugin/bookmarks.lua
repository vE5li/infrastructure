local keys = {
    { "<leader>bt", function() require("bookmarks").bookmark_toggle() end, desc = "Add or remove a bookmark" },
    { "<leader>be", function() require("bookmarks").bookmark_ann() end, desc = "Add or edit a bookmark" },
    { "<leader>bc", function() require("bookmarks").bookmark_clean() end, desc = "Remove all bookmarks in this buffer" },
    { "<leader>bC", function() require("bookmarks").bookmark_clear_all() end, desc = "Remove all bookmarks" },
    { "<leader>bn", function() require("bookmarks").bookmark_next() end, desc = "Jump to next bookmark" },
    { "<leader>bN", function() require("bookmarks").bookmark_prev() end, desc = "Jump to previous bookmark" },
    { "<leader>bl", function() require("bookmarks").bookmark_list() end, desc = "Show bookmark list in quickfix window" },
    { "lb", function() require('telescope').extensions.bookmarks.list() end, desc = "Show bookmarks in telescope" },
}

return {
    've5li/bookmarks.nvim',
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = true,
    keys = keys,
    event = { "VeryLazy" },
    dev = true,
    enabled = OnlyOnDev,
}
