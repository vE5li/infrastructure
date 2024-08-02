return {
    "johmsalas/text-case.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
        require("textcase").setup({})
        require("telescope").load_extension("textcase")
    end,
    keys = {
        "<leader>c", -- Default invocation prefix
        { "<leader>cl", ":TextCaseOpenTelescope<cr>",                                    mode = { "n", "v" },              desc = "Convert using Telescope" },
        { "<leader>cs", function() require('textcase').operator('to_snake_case') end,    desc = "Convert to snake case" },
        { "<leader>cp", function() require('textcase').operator('to_pascal_case') end,   desc = "Convert to pascal case" },
        { "<leader>cP", function() require('textcase').operator('to_phrase_case') end,   desc = "Convert to phrase case" },
        { "<leader>cc", function() require('textcase').operator('to_constant_case') end, desc = "Convert to constant case" },
        { "<leader>cu", function() require('textcase').operator('to_lower_case') end,    desc = "Convert to lower case" },
        { "<leader>cU", function() require('textcase').operator('to_upper_case') end,    desc = "Convert to upper case" },
        { "<leader>c/", function() require('textcase').operator('to_path_case') end,     desc = "Convert to path case" },
    },
}
