local function open()
    if vim.fn.getwininfo(vim.fn.win_getid())[1].terminal == 1 then
        local working_directory = vim.fn.getcwd();
        package.loaded.oil.open(working_directory)
    else
        local buffer_path = vim.api.nvim_buf_get_name(0)
        local buffer_directory = vim.fn.fnamemodify(buffer_path, ":h")
        package.loaded.oil.open(buffer_directory)
    end
end

local opts = {
    -- Instantly close buffers after selecting a file
    cleanup_delay_ms = 0,
    keymaps = {
        -- Remap toggling of hidden files to "th"
        ["th"] = "actions.toggle_hidden",
        ["g."] = false,
        -- Remap opening file externally to "ge"
        ["ge"] = "actions.open_external",
        ["gx"] = false,
        -- Remap reloading of files to Ctrl+r
        ["<C-r>"] = "actions.refresh",
        ["<C-l>"] = false,
        -- Remap vsplit to be consistent with telescope
        ["<C-v>"] = "actions.select_vsplit",
        -- Key binding to open a new terminal window
        ["<C-t>"] = function()
            local directory = package.loaded.oil.get_current_dir()
            local bufnr = vim.api.nvim_create_buf(true, false)
            vim.api.nvim_set_current_buf(bufnr)
            vim.fn.termopen(vim.o.shell, { cwd = directory })
            vim.api.nvim_buf_set_name(bufnr, directory .. ".terminal")
        end,
        -- Copy the path of the selected entry
        -- TODO: Hightlight yanked entry somehow
        ["gyp"] = "actions.copy_entry_path",
        -- Move working directory
        ["gcd"] = function()
            local directory = package.loaded.oil.get_current_dir()
            print("changing working directory to " .. directory)
            vim.fn.chdir(directory)
        end,
    },
    view_options = {
        -- Always show parent directory.
        is_hidden_file = function(name)
            local m = name:match("^%.")
            return m ~= nil and name ~= ".."
        end,
    },
}

local keys = {
    { "-", open, desc = "Open directory view" },
}

return {
    'stevearc/oil.nvim',
    config = true,
    opts = opts,
    keys = keys,
    -- Since oil hijacks the file explorer we can't lazy load it
    lazy = false,
}
