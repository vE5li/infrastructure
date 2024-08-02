local function set_bindings(buffer_options)
    local gitsings = package.loaded.gitsigns

    -- Staging
    vim.keymap.set('n', 'ms', gitsings.stage_hunk, { desc = "Stage hunk" })
    vim.keymap.set('n', 'mu', gitsings.undo_stage_hunk, { desc = "Unstage hunk" })
    vim.keymap.set('n', 'mr', gitsings.reset_hunk, { desc = "Reset hunk" })
    vim.keymap.set('v', 'ms', function() gitsings.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
        { desc = "Stage hunk" })
    vim.keymap.set('v', 'mr', function() gitsings.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
        { desc = "Unstage hunk" })
    vim.keymap.set('n', 'mS', gitsings.stage_buffer, { desc = "Stage buffer" })
    vim.keymap.set('n', 'mU', gitsings.reset_buffer_index, { desc = "Unstage buffer" })
    vim.keymap.set('n', 'mR', gitsings.reset_buffer, { desc = "Reset buffer" })

    -- Tools
    vim.keymap.set("n", "md", function() gitsings.diffthis("~") end, { desc = "Open diff" })
    vim.keymap.set("n", "mD", gitsings.toggle_deleted, { desc = "Toggle show deleted" })
    vim.keymap.set('n', 'mb', gitsings.blame_line, { desc = "Show blame" })
end

local opts = {
    on_attach = function(buffer_number)
        set_bindings({ buffer = buffer_number })
    end,
    preview_config = {
        border = "none",
        row = 1,
    },
}

return {
    'lewis6991/gitsigns.nvim',
    config = true,
    opts = opts,
    event = { "BufRead", "BufNewFile" },
}
