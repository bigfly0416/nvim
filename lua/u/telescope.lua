local ok, telescope = pcall(require, "telescope")
if not ok then
    print("telescope not installed")
    return
end

local actions = require "telescope.actions"

telescope.load_extension('dap')

telescope.setup({
    defaults = {
        mappings = {
            i = {
                ["<Tab>"] = actions.select_default,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<esc>"] = actions.close,
                ["<CR>"] = actions.select_default,
            }
        },
    }
})


local gerrit = function(opts)
    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local handle = io.popen('git review -l -r origin')

    if handle == nil then
        return
    end
    local action_state = require "telescope.actions.state"
    local result = handle:read("*a")
    handle:close()

    local reviews = {}
    local i = 1
    if result:find('^No') == nil then
        for s in result:gmatch("[^\r\n]+") do
            if s:find('^Found') == nil then
                reviews[i] = s
                i = i + 1
            end
        end
    end
    pickers.new(opts, {
        prompt_title = "gerrit reviews",
        finder = finders.new_table {
            results = reviews
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection ~= nil then
                    local change = string.match(selection[1], '%d*')
                    os.execute('git review -d ' .. change .. ' -r origin')
                    local o, _ = pcall(require, "nvim-tree")
                    if o then
                        vim.cmd("NvimTreeRefresh")
                    end
                end
            end)
            return true
        end,
    }):find()
end


local results = function()
    local tt = require('telescope.themes')
    local tb = require("telescope.builtin")

    return {
        { group = 'Nvimtree', desc = 'locate current file', fn = function() vim.cmd("NvimTreeFindFile") end },
        { group = 'Gerrit', desc = 'pending reviews', function() gerrit(tt.get_dropdown({ previewer = false })) end },
        { group = 'Dap', desc = 'configurations in .vscode/lanuch.json', fn = function()
            local dap = require("dap")
            dap.configurations = {}
            local vs = require("dap.ext.vscode")
            vs.load_launchjs()
            telescope.extensions.dap.configurations {}
        end },
        { group = 'Dap', desc = 'disconnect without terminate', fn = function()
            local dap = require("dap")
            dap.disconnect({ terminateDebuggee = false })
        end },
        { group = 'Dap', desc = 'disconnect and terminate', fn = function()
            local dap = require("dap")
            dap.disconnect({ terminateDebuggee = true })
        end },
        { group = 'Dap', desc = 'breakpoints', fn = function()
            telescope.extensions.dap.list_breakpoints {}
        end },
        { group = 'Vim-test', desc = 'toggle summary', fn = function()
            vim.cmd("UltestSummary")
        end },
        { group = 'Vim-test', desc = 'debug nearest', fn = function()
            vim.cmd("UltestDebugNearest")
        end },
        { group = 'Vim-test', desc = 'test nearest', fn = function()
            vim.cmd("UltestNearest")
        end },
        { group = 'Git', desc = 'current file commits', fn = function()
            tb.git_bcommits({ layout_config = { width = 0.99 } })
        end
        },
        { group = 'Git', desc = 'branches', fn = function()
            tb.git_branches({ layout_config = { width = 0.99 } })
        end
        },
        { group = 'Finder', desc = 'show all diagnostics', fn = function()
            tb.diagnostics({ layout_config = { width = 0.99 } })
        end
        },
    }
end


-- "pin" current working directory when find files
local cwd = "."

local fns = function()
    local tb = require('telescope.builtin')
    local tt = require('telescope.themes')
    local t = "Finder"

    return {
        { key = "<leader>p", fn = function()
            tb.find_files(tt.get_dropdown({
                cwd = cwd,
                previewer = false
            }))
        end, group = t, desc = "find source files" },

        { key = "<leader>P", fn = function()
            tb.find_files(tt.get_dropdown({
                cwd = cwd,
                previewer = false,
                no_ignore = true,
                hidden = true,
            }))
        end, group = t, desc = "find all files" },

        { key = "<leader>f", fn = function()
            tb.live_grep({ layout_config = { width = 0.99 } })
        end, group = t, desc = "live grep source" },

        { key = "<leader>F", fn = function()
            tb.live_grep(
                {
                layout_config = { width = 0.99 },
                additional_args = function() return { "--no-ignore", "--hidden" } end
            }
            )
        end, group = t, desc = "live grep all" },
        {
            key = "<leader>e",
            fn = "<cmd>NvimTreeToggle<cr>",
            group = "Nvimtree",
            desc = "toggle",
        },
    }

end




return function()
    local t = fns()
    local r = results()
    for _, v in ipairs(r) do
        t[#t + 1] = v
    end
    return t
end
