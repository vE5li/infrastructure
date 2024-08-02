-- Clear jump buffer on start
vim.cmd("autocmd VimEnter * :clearjumps")

-- Only show cursor line in the focused window
local cursorline_group = vim.api.nvim_create_augroup("cursorline_group", { clear = true })

vim.api.nvim_create_autocmd("WinEnter",
    { group = cursorline_group, callback = function() vim.wo.cursorline = true end }
)

vim.api.nvim_create_autocmd("WinLeave",
    { group = cursorline_group, callback = function() vim.wo.cursorline = false end }
)

-- Disable line numbers and signs for terminal buffers
local terminal_group = vim.api.nvim_create_augroup("terminal_group", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
    group = terminal_group,
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.scrolloff = 0
        vim.api.nvim_buf_set_keymap(0, "t", "<esc>", "<C-\\><C-n>", {})

        if OnlyOnDev() then
            local crill = require("crill")

            vim.keymap.set("n", "<cr>", crill.toggle_output, { buffer = true, desc = "Toggle command output" })
            vim.keymap.set("n", "ra", crill.run_again, {  buffer = true,desc = "Run command again" })
            vim.keymap.set("n", "rh", crill.run_again_here, { buffer = true, desc = "Run command again here" })
            vim.keymap.set("n", "st", crill.terminate, { buffer = true, desc = "Terminate process" })
            vim.keymap.set("n", "sk", crill.kill, { buffer = true, desc = "Kill process" })
            vim.keymap.set("n", "ss", crill.send_stdin, { buffer = true, desc = "Send Stdin" })
            vim.keymap.set("n", "ci", crill.copy_user_input, { buffer = true, desc = "Copy input" })
            vim.keymap.set("n", "cd", crill.change_directory, { buffer = true, desc = "Change directory" })

            vim.keymap.set("n", "oft", function() crill.set_follow(true) end, { buffer = true, desc = "" })
            vim.keymap.set("n", "off", function() crill.set_follow(false) end, { buffer = true, desc = "" })
            vim.keymap.set("n", "olt", function() crill.set_line_limit(10) end, { buffer = true, desc = "" })
            vim.keymap.set("n", "olf", function() crill.set_line_limit() end, { buffer = true, desc = "" })
            vim.keymap.set("n", "oFt", function() crill.set_frozen(true) end, { buffer = true, desc = "" })
            vim.keymap.set("n", "oFf", function() crill.set_frozen(false) end, { buffer = true, desc = "" })
            vim.keymap.set("n", "oxt", function() crill.set_expand_on_message(true) end, { buffer = true, desc = "" })
            vim.keymap.set("n", "oxf", function() crill.set_expand_on_message(false) end, { buffer = true, desc = "" })
            vim.keymap.set("n", "oot", function() crill.set_show_stdout(true) end, { buffer = true, desc = "" })
            vim.keymap.set("n", "oof", function() crill.set_show_stdout(false) end, { buffer = true, desc = "" })
            vim.keymap.set("n", "oet", function() crill.set_show_stderr(true) end, { buffer = true, desc = "" })
            vim.keymap.set("n", "oef", function() crill.set_show_stderr(false) end, { buffer = true, desc = "" })
            vim.keymap.set("n", "pi", crill.pin_item, { buffer = true, desc = "Pin an item" })
            vim.keymap.set("n", "ui", crill.unpin_item, { buffer = true, desc = "Unpin an item" })
        end
    end
})

if OnlyOnDev() then
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = terminal_group,
        pattern = "*.terminal",
        callback = require("crill").inspect,
    })
end

-- if OnlyOnDev() then
--     vim.api.nvim_create_autocmd("InsertEnter", {
--         group = terminal_group,
--         pattern = "*.terminal",
--         callback = require("crill").inspect,
--     })
-- end

-- Briefly highlight yanked text
local highlight_yank_group = vim.api.nvim_create_augroup("highlight_yank_group", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = highlight_yank_group,
    callback = function()
        vim.highlight.on_yank { higroup = 'HighlightYankedText', timeout = 200 }
    end
})

-- Make the quickfix window bigger
local quickfix_group = vim.api.nvim_create_augroup("quickfix_group", { clear = true })

vim.api.nvim_create_autocmd("FileType",
    {
        group = quickfix_group,
        pattern = "qf",
        callback = function()
            vim.cmd("resize 40")
        end,
    }
)
