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


local results = function()
    local tt = require('telescope.themes')
    local tb = require("telescope.builtin")


    return {
        { group = 'Nvimtree', desc = 'locate current file', fn = function() vim.cmd("NvimTreeFindFile") end },
        { group = 'Gerrit', desc = 'pending reviews', fn = function()
            local sal = require("u.sal")
            sal.gerrit(tt.get_dropdown({ previewer = false }))
        end
        },
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
        { group = 'Git', desc = 'current file commits', fn = function() vim.api.nvim_command [[DiffviewFileHistory]] end,
        },
        { group = 'Git', desc = 'diff changes', fn = function()
            local sal = require("u.sal")
            if not sal.isDir(".git") then
                print("not a git repository")
                return
            end

            local s = sal.shell("git status --porcelain")
            if s == nil or s == "" then
                -- diff latest 2 commit if no changes
                print("no changes")
                return
            end
            vim.api.nvim_command [[DiffviewOpen]]
        end,
        },
        { group = 'Git', desc = 'diff history commit', fn = function()
            local sal = require("u.sal")
            sal.diff(tt.get_dropdown({}))
        end,
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
