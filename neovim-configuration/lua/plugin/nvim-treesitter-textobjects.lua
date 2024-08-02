local function config()
    require('nvim-treesitter.configs').setup({
        textobjects = {
            select = {
                enable = true,
                -- textobjs
                keymaps = {
                    ["if"] = { query = "@function.inner" },
                    ["iF"] = { query = "@function.inner" },
                    ["af"] = { query = "@function.outer" },
                    ["aF"] = { query = "@function.outer" },
                    ["ia"] = { query = "@parameter.inner" },
                    ["aa"] = { query = "@parameter.outer" },
                    ["ic"] = { query = "@call.inner" },
                    ["ac"] = { query = "@call.outer" },
                    ["ir"] = { query = "@statement.outer" },
                    ["iR"] = { query = "@statement.outer" },
                    ["ar"] = { query = "@statement.outer" },
                    ["aR"] = { query = "@statement.outer" },
                },
                -- Logic for when to include whitespaces
                include_surrounding_whitespace = function(data)
                    -- When folding with "zfaf" we don't want to include the empty lines afterwards
                    return data.selection_mode ~= "V" or data.query_string ~= "@function.outer"
                end,
            },
            swap = {
                enable = true,
                swap_next = {
                    ["<leader>a"] = "@parameter.inner",
                },
                swap_previous = {
                    ["<leader>A"] = "@parameter.inner",
                },
            },
        },
    })
end

return {
    'nvim-treesitter/nvim-treesitter-textobjects',
    requires = 'nvim-treesitter/nvim-treesitter',
    config = config,
    event = { "BufRead", "BufNewFile" },
}
