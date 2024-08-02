local opts = {
    default_mappings = false,
}

local keys = {
    { "mco", ":GitConflictChooseOurs<cr>", silent = true, desc = "Choose ours" },
    { "mct", ":GitConflictChooseTheirs<cr>", silent = true, desc = "Choose theirs" },
    { "mcb", ":GitConflictChooseBoth<cr>", silent = true, desc = "Choose both" },
    { "mcn", ":GitConflictChooseNone<cr>", silent = true, desc = "Choose none" },
    { "mgn", ":GitConflictNextConflict<cr>", silent = true, desc = "Goto next conflict" },
    { "mgp", ":GitConflictPrevConflict<cr>", silent = true, desc = "Goto previous conflict" },
    { "mqf", ":GitConflictListQf<cr>", silent = true, desc = "Open conflicts in quick fix list" },
}

return {
    'akinsho/git-conflict.nvim',
    config = true,
    opts = opts,
    keys = keys,
    event = { "BufRead" },
}
