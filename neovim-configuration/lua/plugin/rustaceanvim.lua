local function config()
    vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(arguments)
            local client = vim.lsp.get_client_by_id(arguments.data.client_id)

            if client and client.config.name == "rust-analyzer" then
                local buffer_options = { noremap = true, silent = true, buffer = arguments.buf }

                local function desc(description)
                    buffer_options.desc = description
                    return buffer_options
                end

                vim.keymap.set('n', 'gp', function() vim.cmd.RustLsp('parentModule') end, desc "Go to parent module")
                vim.keymap.set('n', 'ge', function() vim.cmd.RustLsp('relatedDiagnostics') end,
                    desc "Go to related diagnostics")
                vim.keymap.set('n', 'gE', function() vim.cmd.RustLsp('openDocs') end, desc "Go to external documentation")
                vim.keymap.set('n', 'gC', function() vim.cmd.RustLsp('openCargo') end, desc "Go to Cargo.toml")

                vim.keymap.set('n', 'gvh', function() vim.cmd.RustLsp({ 'view', 'hir' }) end, desc "View HIR")
                vim.keymap.set('n', 'gvm', function() vim.cmd.RustLsp({ 'view', 'mir' }) end, desc "View MIR")
                vim.keymap.set('n', 'gvH', function() vim.cmd.Rustc({ 'unpretty', 'hir' }) end, desc "Unpretty HIR")
                vim.keymap.set('n', 'gvM', function() vim.cmd.Rustc({ 'unpretty', 'mir' }) end, desc "Unpretty MIR")

                vim.keymap.set('n', 'gsr', ":RustLsp ssr ",
                    { noremap = true, buffer = arguments.buf, desc = "Structural search replace" })
                vim.keymap.set('n', 'gsw', ":RustLsp workspaceSymbol allSymbols ",
                    { noremap = true, buffer = arguments.buf, desc = "Workspace search" })

                vim.keymap.set('n', '<C-S-d>', function() vim.cmd.RustLsp('renderDiagnostic') end,
                    desc "Show diagnostic like cargo")
            end
        end,
    })
end

return {
    'mrcjkb/rustaceanvim',
    config = config,
    lazy = false,
}
