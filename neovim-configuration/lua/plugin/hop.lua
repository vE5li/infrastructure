local keys = {
    { "gw", function() require("hop").hint_words({ multi_windows = true }) end, desc = "Go to word" },
    { "gl", function() require("hop").hint_lines({ multi_windows = true }) end, desc = "Go to line" },
}

local opts = {
    -- All keys used for jumping
    -- NOTE: Characters for multi-character labels start from the back of the list, so I moved `arstg` there to make it most convenient for my layout
    keys = 'dhklqweyuiopzxcvbnmfjASDGHKLQWERTYUIOPZXCVBNMFJ!"?@$&/\'*:<{[()]}>;\\%|#,.-~_+arstg',
}

return {
    'smoka7/hop.nvim',
    config = true,
    opts = opts,
    keys = keys,
}
