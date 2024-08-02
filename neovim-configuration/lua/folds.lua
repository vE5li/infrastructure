-- Function defining the string displayed on closed folds
function _G.custom_fold_text()
    local ffi = require("ffi");
    ffi.cdef('int curwin_col_off(void);')

    local gutter_width = ffi.C.curwin_col_off()
    local width = vim.api.nvim_win_get_width(0) - gutter_width
    local line = vim.fn.getline(vim.v.foldstart)

    local line_count = " " .. (vim.v.foldend - vim.v.foldstart + 1) .. " lines "
    local spacing = (" "):rep(width - vim.fn.strwidth(line_count) - vim.fn.strwidth(line))

    return line .. spacing .. line_count
end
