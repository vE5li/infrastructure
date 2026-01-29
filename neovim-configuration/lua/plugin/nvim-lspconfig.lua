local function config()
    -- Set up autocommand for key bindings
    vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(arguments)
            local buffer_options = { noremap = true, silent = true, buffer = arguments.buf }

            -- Set up Keybindings

            local function desc(description)
                buffer_options.desc = description
                return buffer_options
            end

            -- Goto
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, desc "Go to definition")
            vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, desc "Go to type definition")
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, desc "Go to implementation")
            vim.keymap.set('n', 'grf', vim.lsp.buf.references, desc "Go to references")
            vim.keymap.set('n', 'gh', vim.lsp.buf.signature_help, desc "Show signature help")

            -- Refactoring
            vim.keymap.set('n', 'hrn', vim.lsp.buf.rename, desc "Rename")
            vim.api.nvim_create_user_command("Fmt", function()
                vim.lsp.buf.format({
                    timeout_ms = 5000,
                    async = true,
                })
            end, { desc = "Run formatter on this file" })
        end,
    })

    -- HACK: Since treesitter doesn't automatically turn on the syntax highlighting for WGSL, we do it with an autocommand for now
    local wgsl_group = vim.api.nvim_create_augroup("wgsl_group", { clear = true })
    vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
        group = wgsl_group,
        pattern = "*.wgsl",
        callback = function()
            vim.bo.filetype = "wgsl"
            vim.cmd("TSBufEnable highlight")
        end,
    })

    -- HACK: Workaround for lua_ls setting the foldmethod to `expr`.
    -- See: https://github.com/neovim/neovim/discussions/34933
    local foldmethod_group = vim.api.nvim_create_augroup("foldmethod_group", { clear = true })
    vim.api.nvim_create_autocmd({ "Filetype" }, {
        pattern = { "lua" },
        group = foldmethod_group,
        callback = function()
            vim.wo.foldmethod = "manual"
        end,
    })

    -- Nix
    vim.lsp.config("nil_ls", {
        settings = {
            ["nil"] = {
                formatting = {
                    command = { "nix", "fmt", "--", "--quiet" }
                }
            }
        }
    })

    -- Lua
    vim.lsp.config("lua_ls", {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            diagnostics = {
                globals = {
                    'vim',
                    'require',
                    'use',
                },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
        },
    })

    vim.lsp.enable({
        "nil_ls",
        "ts_ls",
        "kotlin_language_server",
        "pylsp",
        "lua_ls",
        "terraformls",
    })
end

return {
    'neovim/nvim-lspconfig',
    config = config,
    lazy = false,
}
