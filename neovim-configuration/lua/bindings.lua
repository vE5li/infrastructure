-- Extra bindings
vim.keymap.set("n", "<C-q>", function() vim.api.nvim_command('let @/ = ""') end, { desc = "Clear search register" })
vim.keymap.set("v", "sh", '"ay:s/<C-r>a/', { desc = "Substitute here" })
vim.keymap.set("v", "sf", '"ay:%s/<C-r>a/', { desc = "Substitute in file" })

-- Faster cursor movement
vim.keymap.set("n", "<S-Up>", '10k', { desc = "Go up 10 lines" })
vim.keymap.set("n", "<S-Down>", '10j', { desc = "Go down 10 lines" })

-- Switching windows
vim.keymap.set("n", "wq", "<C-w>q", { silent = true, desc = "Close window" })
vim.keymap.set("n", "wi", "<C-w><C-l>", { silent = true, desc = "Select right window" })
vim.keymap.set("n", "wn", "<C-w><C-h>", { silent = true, desc = "Select left window" })
vim.keymap.set("n", "wu", "<C-w><C-k>", { silent = true, desc = "Select top window" })
vim.keymap.set("n", "we", "<C-w><C-j>", { silent = true, desc = "Select bottom window" })
vim.keymap.set("n", "<C-b>", ":b#<cr>", { silent = true, desc = "Go to previous buffer" })
vim.keymap.set("n", "<C-z>", ":bw<cr>", { silent = true, desc = "Close current buffer" })

-- Moving windows
vim.keymap.set("n", "wI", "<C-w>L", { silent = true, desc = "Move window right" })
vim.keymap.set("n", "wN", "<C-w>H", { silent = true, desc = "Move window left" })
vim.keymap.set("n", "wU", "<C-w>K", { silent = true, desc = "Move window up" })
vim.keymap.set("n", "wE", "<C-w>J", { silent = true, desc = "Move window down" })
vim.keymap.set("n", "wt", "<C-w>T", { silent = true, desc = "Move window to tab" })

-- Unset 'gd' and 'gD'
-- These bindings will be set again by lspconfig
vim.keymap.set("n", "gd", function() end, { silent = true })
vim.keymap.set("n", "gD", function() end, { silent = true })

-- Add new empty line above the cursor without chaning mode
vim.keymap.set({ "n", "i" }, "<C-j>", function()
    local position = vim.api.nvim_win_get_cursor(0)
    local lines = vim.api.nvim_buf_get_lines(0, position[1] - 1, position[1], true);
    vim.api.nvim_buf_set_lines(0, position[1] - 1, position[1], true, { "", lines[1] });
    vim.api.nvim_win_set_cursor(0, { position[1] + 1, position[2] })
end, { desc = "Empty line above" })

-- Add new empty line below the cursor without chaning mode
vim.keymap.set({ "n", "i" }, "<C-k>", function()
    local position = vim.api.nvim_win_get_cursor(0)
    local lines = vim.api.nvim_buf_get_lines(0, position[1] - 1, position[1], true);
    vim.api.nvim_buf_set_lines(0, position[1] - 1, position[1], true, { lines[1], "" });
end, { desc = "Empty line below" })

-- Check if keymap is set
function IsKeymapPresent(keymaps, keys)
    for _, keymap in ipairs(keymaps) do
        if keymap.lhs == keys then
            return true
        end
    end

    return false
end

-- Terminal
vim.keymap.set("n", "<C-t>", function()
    local terminal_name = vim.fn.input("terminal name: ")
    if terminal_name ~= nil and terminal_name ~= "" then
        vim.cmd("term")
        vim.cmd("keepalt file " .. terminal_name .. ".terminal")
    end
end, { desc = "Open new terminal buffer" })
vim.keymap.set("t", "<S-esc>", "<C-\\><C-n>", { desc = "Exit terminal insert mode" })
vim.keymap.set("n", "<leader>l", function()
    local keymaps = vim.api.nvim_buf_get_keymap(0, "t")

    if IsKeymapPresent(keymaps, "<Esc>") then
        vim.api.nvim_buf_del_keymap(0, "t", "<Esc>")
    else
        vim.api.nvim_buf_set_keymap(0, "t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal insert mode" })
    end
end, { desc = "Toggle terminal escape mode" })
