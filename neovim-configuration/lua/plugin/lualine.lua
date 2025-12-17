local function config()
    local lualine = require('lualine')
    local colors = require('colors')

    local conditions = {
        buffer_not_empty = function()
            return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
        end,
        hide_in_width = function()
            return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
            local filepath = vim.fn.expand('%:p:h')
            local git_directory = vim.fn.finddir('.git', filepath .. ';')
            local jujutsu_directory = vim.fn.finddir('.jj', filepath .. ';')
            return #jujutsu_directory == 0 and #git_directory > 0 and #git_directory < #filepath
        end,
        check_jujutsu_workspace = function()
            local filepath = vim.fn.expand('%:p:h')
            local jujutsu_directory = vim.fn.finddir('.jj', filepath .. ';')
            return #jujutsu_directory > 0 and #jujutsu_directory < #filepath
        end,
        treesitter_support = function()
            return package.loaded["nvim-treesitter"] ~= nil and
                require("nvim-treesitter.ts_utils").get_node_at_cursor() ~= nil
        end,
        in_terminal_mode = function()
            local mode = vim.api.nvim_get_mode().mode
            return mode == "t" or mode == "nt"
        end,
        in_visual_mode = function()
            -- \22 for the blockwise visual mode, with mode name ^V (ascii character 0x16)
            return vim.fn.mode():find("[vV\22]") ~= nil
        end
    }

    -- Config
    local config_table = {
        options = {
            -- Disable sections and component separators
            component_separators = '',
            section_separators = '',
            theme = {
                -- We are going to use lualine_c an lualine_x as left and
                -- right section. Both are highlighted by c theme .  So we
                -- are just setting default looks o statusline
                normal = { c = { fg = colors.base06, bg = colors.base02 } },
                inactive = { c = { fg = colors.base06, bg = colors.base02 } },
            },
            refresh = {
                statusline = 100,
            },
        },
        sections = {
            -- these are to remove the defaults
            lualine_a = {},
            lualine_b = {},
            lualine_y = {},
            lualine_z = {},
            -- These will be filled later
            lualine_c = {},
            lualine_x = {},
        },
        inactive_sections = {
            -- these are to remove the defaults
            lualine_a = {},
            lualine_b = {},
            lualine_y = {},
            lualine_z = {},
            lualine_c = {},
            lualine_x = {},
        },
    }

    -- Inserts a component in lualine_c at left section
    local function ins_left(component, both)
        table.insert(config_table.sections.lualine_c, component)
        if both then
            table.insert(config_table.inactive_sections.lualine_c, component)
        end
    end

    -- Inserts a component in lualine_x ot right section
    local function ins_right(component, both)
        table.insert(config_table.sections.lualine_x, component)
        if both then
            table.insert(config_table.inactive_sections.lualine_x, component)
        end
    end

    -- auto change color according to neovims mode
    local mode_color = {
        n = colors.base0B,
        i = colors.base09,
        v = colors.base0E,
        [''] = colors.base0E,
        V = colors.base0E,
        c = colors.base0C,
        no = colors.base08,
        s = colors.base09,
        S = colors.base09,
        [''] = colors.base09,
        ic = colors.base0A,
        R = colors.base0E,
        Rv = colors.base0E,
        cv = colors.base08,
        ce = colors.base08,
        r = colors.base0C,
        rm = colors.base0C,
        ['r?'] = colors.base0C,
        ['!'] = colors.base08,
        t = colors.base08,
        nt = colors.base0C,

        MultiNormal = colors.base0A,
        MultiVisual = colors.base09,
        MultiInsert = colors.base0B,
        FindMode = colors.base09,
    }

    local function get_mode_name()
        local name = vim.api.nvim_get_mode().mode

        if vim.g.libmodalActiveModeName then
            name = vim.g.libmodalActiveModeName
        end

        return name
    end

    local function get_mode_color()
        return mode_color[get_mode_name()]
    end

    local function get_jujutsu_closest_bookmark()
        local directory = vim.fn.expand("%:p:h")
        local command = "cd " .. vim.fn.shellescape(directory) .. " && jj log -r 'closest_bookmark(@)' --template 'self.local_bookmarks()' --color=never --no-graph --ignore-working-copy"


        local handle = io.popen(command)

        if not handle then
            return ""
        end

        local result = handle:read("*a")
        handle:close()

        return " " .. result
    end

    local function get_node_type()
        if package.loaded["nvim-treesitter"] ~= nil then
            local node = require("nvim-treesitter.ts_utils").get_node_at_cursor();
            if node ~= nil then
                return node:type()
            end
        end
    end

    local function get_battery_charges()
        local function for_file(path)
            local stat = vim.uv.fs_stat(path)

            if stat then
                local file = assert(io.popen("cat " .. path, 'r'))
                local output = assert(file:read('*a'))
                file:close()

                return tonumber(output:match("[0-9]*"))
            end
        end

        local charges = {}
        local paths = {
            "/sys/class/power_supply/BAT0",
            "/sys/class/power_supply/BAT1"
        }

        for _, path in ipairs(paths) do
            local charge = for_file(path .. "/capacity")

            if charge then
                charges[path] = charge
            end
        end

        return charges
    end

    local function get_battery_charging(path)
        local stat = vim.uv.fs_stat(path .. "/status")

        if stat then
            local file = assert(io.popen("cat " .. path .. "/status", 'r'))
            local output = assert(file:read('*a'))
            file:close()

            return output:match("Charging") ~= nil
        end

        return false
    end

    local battery_lookup = {
        { [false] = "󰂎", [true] = "󰢟 " },
        { [false] = "󰁺", [true] = "󰢜 " },
        { [false] = "󰁻", [true] = "󰂆 " },
        { [false] = "󰁼", [true] = "󰂇 " },
        { [false] = "󰁽", [true] = "󰂈 " },
        { [false] = "󰁾", [true] = "󰢝 " },
        { [false] = "󰁿", [true] = "󰂉 " },
        { [false] = "󰂀", [true] = "󰢞 " },
        { [false] = "󰂁", [true] = "󰂊 " },
        { [false] = "󰂂", [true] = "󰂋 " },
        { [false] = "󰁹", [true] = "󰂅 " },
    }

    -- Color block
    ins_left({
        function()
            return '▊'
        end,
        color = function()
            local color = get_mode_color()
            return { fg = color }
        end,
        padding = { left = 0, right = 1 }, -- We don't need space before this
    }, true)

    -- Macro recording status
    ins_left({
        require("noice").api.status.mode.get,
        cond = require("noice").api.status.mode.has,
        color = { fg = colors.base09 },
    })

    -- Current file path
    ins_left({
        'filename',
        path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
        cond = conditions.buffer_not_empty,
        color = function()
            local color = get_mode_color()
            return { fg = color, gui = 'italic' }
        end,
    }, true)

    -- Line and column
    ins_left({
        'location',
        color = function()
            local color = get_mode_color()
            return { fg = color, gui = 'bold' }
        end,
    }, false)

    -- Number of selected characters and lines
    ins_left({
        function()
            local line_start = vim.fn.line("v")
            local line_end = vim.fn.line(".")

            local words = vim.fn.wordcount().visual_chars
            local lines = line_start <= line_end
                and line_end - line_start + 1
                or line_start - line_end + 1

            return "(" .. tostring(words) .. "+" .. tostring(lines) .. ")"
        end,
        cond = conditions.in_visual_mode,
        color = function()
            local color = get_mode_color()
            return { fg = color, gui = 'italic' }
        end,
        padding = { left = 0 },
    }, false)

    -- LSP diagnostics
    ins_left({
        'diagnostics',
        sources = { 'nvim_diagnostic' },
        symbols = { error = ' ', warn = ' ', info = ' ' },
        diagnostics_color = {
            error = { fg = colors.base08 },
            warn = { fg = colors.base0A },
            info = { fg = colors.base0A },
        },
    }, false)

    -- `Esc` lock indicator
    ins_left({
        function()
            local keymaps = vim.api.nvim_buf_get_keymap(0, "t")
            if IsKeymapPresent(keymaps, "<Esc>") then
                return "󰿆"
            else
                return "󰌾"
            end
        end,
        cond = conditions.in_terminal_mode,
        color = function()
            local color = get_mode_color()
            return { fg = color, gui = 'bold' }
        end,
    }, false)

    -- Add components to right sections

    -- Current treesitter node type
    ins_right({
        get_node_type,
        icon = '󰔱',
        cond = conditions.treesitter_support,
    }, false)

    -- Current branch
    ins_right({
        'branch',
        icon = '',
        cond = conditions.check_git_workspace,
    }, true)

    -- Current Jujutsu change id
    ins_right({
        function()
            return get_jujutsu_closest_bookmark()
        end,
        cond = conditions.check_jujutsu_workspace,
    }, true)

    -- Lines added/changed/removed
    ins_right({
        'diff',
        -- Is it me or the symbol for modified us really weird
        symbols = { added = ' ', modified = ' ', removed = ' ' },
        diff_color = {
            added = { fg = colors.base0B },
            modified = { fg = colors.base09 },
            removed = { fg = colors.base08 },
        },
        cond = conditions.hide_in_width,
    }, false)

    -- Battery
    ins_right({
        function()
            local charges = get_battery_charges()

            if next(charges) ~= nil then
                local icons = ""

                for path, charge in pairs(charges) do
                    local is_charging = get_battery_charging(path)
                    local stage = math.floor(charge / 10)

                    icons = icons .. battery_lookup[stage][is_charging]
                end

                return icons
            end

            return "󰍹"
        end,
        color = function()
            local charges = get_battery_charges()
            local color = colors.base04

            if next(charges) ~= nil then
                for _, charge in pairs(charges) do
                    if charge < 30 then
                        color = colors.base08
                        break
                    end
                end
            end

            return { fg = color }
        end,
        padding = { left = 1 },
    }, true)

    -- Time
    ins_right({
        function()
            return os.date("%H:%M", os.time())
        end,
        color = function()
            local color = get_mode_color()
            return { fg = color, gui = 'bold' }
        end,
        padding = { left = 1 },
    }, true)

    -- Day of the week
    ins_right({
        function()
            local daysoftheweek = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
            return daysoftheweek[os.date("*t").wday]
        end,
        color = function()
            local color = get_mode_color()
            return { fg = color, gui = 'italic' }
        end,
        padding = { left = 2 },
    }, true)

    -- Date
    ins_right({
        function()
            return os.date("%d-%m-%Y", os.time())
        end,
        padding = { left = 2 },
    }, true)

    -- Color block
    ins_right({
        function()
            return '▊'
        end,
        color = function()
            local color = get_mode_color()
            return { fg = color }
        end,
        padding = { left = 1 },
    }, true)

    -- Initialize lualine
    lualine.setup(config_table)

    -- Don't show --MODE-- and position
    vim.api.nvim_command("set noru")
    vim.api.nvim_command("set nosmd")

    -- Update the statusline when entering a libmodal mode
    vim.api.nvim_create_autocmd('ModeChanged', {
        callback = function()
            require('lualine').refresh { scope = 'window', place = { 'statusline' } }
        end
    })
end

return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons', 'folke/noice.nvim' },
    config = config,
}
