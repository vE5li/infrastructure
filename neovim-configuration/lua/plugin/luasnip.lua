local function config()
    local luasnip = require("luasnip")
    local types = require("luasnip.util.types")
    local repeat_node = require("luasnip.extras").rep

    luasnip.setup({
        update_events = { "TextChanged", "TextChangedI" },
    })

    luasnip.add_snippets("lua", {
        -- Function
        luasnip.snippet("function", {
            luasnip.text_node("-- "),
            repeat_node(2),
            luasnip.text_node({ " function", "" }),
            luasnip.choice_node(1, {
                luasnip.text_node("local "),
                luasnip.text_node(""),
            }),
            luasnip.text_node("function "),
            luasnip.insert_node(2),
            luasnip.text_node("("),
            luasnip.insert_node(3),
            luasnip.text_node({ ")", "\t" }),
            luasnip.insert_node(0),
            luasnip.text_node({ "", "end" }),
        }),

        -- Require
        luasnip.snippet("require", {
            -- local or not
            luasnip.choice_node(1, {
                luasnip.text_node("local "),
                luasnip.text_node(""),
            }),
            -- Variable name
            luasnip.function_node(function(path)
                local parts = vim.split(path[1][1], ".", { plain = true, trimempty = true })
                return parts[#parts] or ""
            end, { 2 }),
            luasnip.text_node(" = require('"),
            luasnip.insert_node(2),
            luasnip.text_node("')"),
        }),
    })

    luasnip.add_snippets("rust", {
        -- Add test module
        luasnip.snippet("tests", {
            luasnip.text_node({ "#[cfg(test)]", "mod test {", "\t" }),
            luasnip.insert_node(0),
            luasnip.text_node({ "", "}" }),
        }),

        -- Function
        luasnip.snippet("function", {
            luasnip.choice_node(1, {
                luasnip.text_node("pub"),
                luasnip.text_node("pub asycn"),
                luasnip.text_node("pub const"),
                luasnip.text_node(""),
                luasnip.text_node("asycn"),
                luasnip.text_node("const"),
            }),
            luasnip.text_node(" fn "),
            luasnip.insert_node(2),
            luasnip.text_node("("),
            luasnip.insert_node(3),
            luasnip.text_node(") "),
            luasnip.function_node(function(return_type)
                if #return_type[1][1] > 0 then
                    return "-> "
                end
                return ""
            end, { 4 }),
            luasnip.insert_node(4),
            luasnip.text_node({ " {", "\t" }),
            luasnip.insert_node(0),
            luasnip.dynamic_node(5, function(return_type)
                if vim.fn.match(return_type, "Option") == 0 then
                    return luasnip.sn(nil, luasnip.text_node({ "", "\tNone" }))
                end

                return luasnip.sn(nil, luasnip.text_node(""))
            end, { 4 }),
            luasnip.text_node({ "", "}" }),
        }),

        -- Closure
        luasnip.snippet("closure", {
            luasnip.text_node("|"),
            luasnip.insert_node(1),
            luasnip.text_node("|"),
            luasnip.function_node(function(return_type)
                if #return_type[1][1] > 0 then
                    return " -> "
                end
                return ""
            end, { 2 }),
            luasnip.insert_node(2),
            luasnip.text_node(" "),
            luasnip.dynamic_node(4, function(arguments)
                if #arguments[1][1] > 0 or #arguments[2] > 1 then
                    return luasnip.sn(nil, luasnip.text_node({ "{", "\t" }))
                end

                return luasnip.sn(nil, luasnip.text_node(""))
            end, { 2, 3 }),
            luasnip.insert_node(3),
            luasnip.dynamic_node(5, function(arguments)
                if #arguments[1][1] > 0 or #arguments[2] > 1 then
                    return luasnip.sn(nil, luasnip.text_node({ "", "}" }))
                end

                return luasnip.sn(nil, luasnip.text_node(""))
            end, { 2, 3 }),
        }),
    })
end

local keys = {
    -- {
    --     "<C-k>",
    --     mode = { "i" },
    --     function() package.loaded.luasnip.expand() end,
    --     { silent = true },
    --     desc = "longer go multiline you dick",
    -- },
    {
        "<C-ö>",
        mode = { "i", "s" },
        function() package.loaded.luasnip.jump(1) end,
        { silent = true },
        desc = "",
    },
    {
        "<C-h>",
        mode = { "i", "s" },
        function() package.loaded.luasnip.jump(-1) end,
        { silent = true },
        desc = "",
    },
    {
        "<C-ü>",
        mode = { "i", "s" },
        function()
            if package.loaded.luasnip.choice_active() then
                package.loaded.luasnip.change_choice(1)
            end
        end,
        silent = true,
        desc = "",
    },
    {
        "<C-f>",
        mode = { "i", "s" },
        function() require("luasnip.extras.select_choice")() end,
        silent = true,
        desc = "",
    },
}

return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    config = config,
    keys = keys,
}
