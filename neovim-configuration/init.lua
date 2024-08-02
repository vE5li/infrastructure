-- Function for inspecting tables
P = function(value)
    print(vim.inspect(value))
    return value
end

-- Function to only enable plugins on a certain machine.
OnlyOnDev = function()
    local hostname = vim.fn.readfile("/etc/hostname")[1]
    return string.find(hostname, "computer") ~= nil
end

-- Laeder key
vim.g.mapleader = "h"

-- Modules
require("options")
require("plugins")
require("bindings")
require("folds")
require("diagnostics")
require("autocommands")
