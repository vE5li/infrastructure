-- Diagnostics configuration
vim.diagnostic.config({
    virtual_text = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "󰍉",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticError",
            [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticHint",
        },
    },
    update_in_insert = true,
    underline = true,
    severity_sort = false,
    float = {
        border = 'none',
        source = true,
        header = '',
        prefix = '',
    },
})

vim.keymap.set("n", "<C-d>", function() vim.diagnostic.open_float(nil, { focusable = false }) end,
    { desc = "Open diagnostics" })
