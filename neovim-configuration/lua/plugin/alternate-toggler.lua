local opts = {
    alternates = {
        yes = "no",
        always = "never",
        on = "off",
    }
}

local keys = {
    { "<leader>t", function() package.loaded["alternate-toggler"].toggleAlternate() end }
}

return {
    'rmagatti/alternate-toggler',
    config = true,
    opts = opts,
    keys = keys,
}
