-- Disable greeting message
vim.opt.shortmess = vim.opt.shortmess + { I = true }

-- Enable the sign column
vim.opt.signcolumn = "yes"

-- Make the cursor a block cursor in every mode
vim.opt.guicursor = "n-c:block-Cursor,i-ci:hor50,o-r-cr:ver50"

-- Show line numbers
vim.opt.number = true

-- Add a cursorline
vim.opt.cursorline = true

-- Number of spaces tab counts for
vim.opt.tabstop = 4

-- Number of spaces to use for each step of (auto)indent
vim.opt.shiftwidth = 4

-- Number of spaces tab counts for while editing (e.g. pressing <tab>)
vim.opt.softtabstop = 4

-- Replace inserted tab characters with spaces in insert mode
vim.opt.expandtab = true

-- Text in searches is case insensitive unless there are capital letters in the text
vim.opt.smartcase = true

-- Use OS clipboard for all internal copy operations
vim.opt.clipboard = "unnamedplus"

-- Make <left> and <right> wrap to adjacent lines
vim.opt.whichwrap = "<,>"

-- Render control characters
vim.opt.list = true

-- Don't create a swapfile when editing file buffers
vim.opt.swapfile = false

-- Minimal number of screen lines to keep above and below the cursor
vim.opt.scrolloff = 8

-- Ask for confirmation to close a buffer instead of failing if there are unsaved changes
vim.opt.confirm = true

-- Make the jumplist behave like the tagstack or like a web browser
vim.opt.jumpoptions = "clean,stack"

-- Create folds manually
vim.opt.foldmethod = "manual"

-- Set custom fold text
vim.opt.foldtext = 'v:lua.custom_fold_text()'

-- Allow cursor to move past line boundaries
vim.opt.virtualedit = "all"

-- Disable timing in mappings
vim.opt.timeout = false
