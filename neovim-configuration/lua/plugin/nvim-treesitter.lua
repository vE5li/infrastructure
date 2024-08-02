local opts = {
    ensure_installed = { "lua", "rust", "toml" },
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    ident = { enable = true },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
    }
}

return {
    'nvim-treesitter/nvim-treesitter',
    config = true,
    opts = opts,
    event = { "BufRead", "BufNewFile" },
    build = ":TSUpdate",
}
