local function config()
    local yop = require("yop")

    -- Go to start of a text object
    yop.op_map({ "n", "v" }, "gs", function() end, { desc = "Go to start of text object" })

    -- Go to end of a text object
    yop.op_map({ "n", "v" }, "ge", function(lines, info)
        local position = info.position.last
        vim.api.nvim_win_set_cursor(0, { position[1], position[2] })
    end, { desc = "Go to end of text object" })

    -- New put implementation that works on text objects
    yop.op_map({ "n" }, "p", function(old_lines)
        local new_text = vim.api.nvim_exec("echo getreg('+')", true);

        -- Save to clipboard
        local clipboard_text = table.concat(old_lines, "\n")
        vim.fn.setreg("+", clipboard_text)

        return { new_text }
    end, { desc = "Paste to text object", assassinate = true })

    -- New put implementation that works on text objects, but without copying the deleted text
    yop.op_map({ "n" }, "P", function()
        return { vim.api.nvim_exec("echo getreg('+')", true) }
    end, { desc = "Paste to text object", assassinate = true })

    -- Remap put operations so they are still accessible
    vim.keymap.set("n", "pp", ":norm! p<cr>", { silent = true, desc = "Put text after the cursor" })
    vim.keymap.set("n", "Pp", ":norm! P<cr>", { silent = true, desc = "Put text before the cursor" })
end

return {
    "ve5li/yop.nvim",
    config = config,
    event = { "BufRead", "BufNewFile" },
}
