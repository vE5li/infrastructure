local function layout_strategy(picker, columns, lines, layout_config)
    local border = 4
    local border_total = border * 2
    local width = math.max(columns - border_total, 0)
    local height = math.max(lines - border_total, 0)

    local results = {
        title = picker.results_title,
        border = false,
        enter = false,
        height = math.max(math.floor(height / 2), 1),
        width = width,
        line = border,
        col = border + 1,
    }

    local prompt = {
        title = picker.prompt_title,
        border = true,
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        enter = true,
        height = 1,
        width = math.max(width - 2, 0),
        line = results.line + results.height + 1,
        col = results.col + 1,
    }

    local preview = {
        title = picker.preview_title,
        border = false,
        enter = false,
        highlight = false,
        height = math.max(height - results.height - prompt.height, 1),
        width = width,
        line = prompt.line + prompt.height + 1,
        col = results.col,
    }

    return {
        results = results,
        prompt = prompt,
        preview = preview,
    }
end

local opts = {
    defaults = {
        border = false,
        layout_strategy = "simple",
    },
    pickers = {
        buffers = {
            mappings = {
                i = {
                    ["<C-d>"] = function(prompt_bufrn) require('telescope.actions').delete_buffer(prompt_bufrn) end
                },
                n = {
                    ["<C-d>"] = function(prompt_bufrn) require('telescope.actions').delete_buffer(prompt_bufrn) end
                }
            }
        }
    }
}

local config = function()
    require("telescope").setup(opts)
    require("telescope").load_extension("ui-select")
    require("telescope.pickers.layout_strategies").simple = layout_strategy
end

local keys = {
    {
        "lf",
        ":Telescope find_files<cr>",
        silent = true,
        desc =
        "Find files"
    },
    {
        "lF",
        ":Telescope oldfiles<cr>",
        silent = true,
        desc =
        "Find recent files"
    },
    {
        "lg",
        ":Telescope live_grep<cr>",
        silent = true,
        desc =
        "Find text"
    },
    {
        "lG",
        ":Telescope lsp_workspace_symbols<cr>",
        silent = true,
        desc =
        "Find lsp symbols in workspace"
    },
    {
        "lt",
        ":Telescope current_buffer_fuzzy_find<cr>",
        silent = true,
        desc =
        "Fuzzy find in current buffer"
    },
    {
        "lw",
        ":Telescope grep_string<cr>",
        silent = true,
        desc =
        "Find word under cursor"
    },
    {
        "ls",
        ":Telescope buffers<cr>",
        silent = true,
        desc =
        "Find buffers"
    },
    {
        "lr",
        ":Telescope treesitter<cr>",
        silent = true,
        desc =
        "Find symbols in buffer"
    },
    {
        "lR",
        ":Telescope lsp_document_symbols<cr>",
        silent = true,
        desc =
        "Find lsp symbols in buffer"
    },
    {
        "lc",
        ":Telescope commands<cr>",
        silent = true,
        desc =
        "Find command"
    },
    {
        "lC",
        ":Telescope command_history<cr>",
        silent = true,
        desc =
        "Find command from history"
    },
    {
        "lk",
        ":Telescope keymaps<cr>",
        silent = true,
        desc =
        "Find keymaps"
    },
    {
        "lmc",
        ":Telescope git_bcommits<cr>",
        silent = true,
        desc =
        "Find commits in buffer"
    },
    {
        "lmc",
        mode = "v",
        function() require('telescope.builtin').git_bcommits_range() end,
        desc =
        "Find commits in selection"
    },
    {
        "lM",
        ":lua require('telescope.builtin').man_pages({ sections={ 'ALL' } })<cr>",
        silent = true,
        desc =
        "Find manual pages"
    },
    {
        "lh",
        ":lua require('telescope.builtin').help_tags()<cr>",
        silent = true,
        desc =
        "Find help pages"
    },
    {
        "L",
        ":Telescope resume<cr>",
        silent = true,
        desc =
        "Resume last picker"
    },
}

return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-ui-select.nvim' },
    config = config,
    keys = keys,
    cmd = "Telescope",
}
