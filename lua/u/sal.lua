local actions = require "telescope.actions"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local action_state = require "telescope.actions.state"

local shell = function(s)
    local handle = io.popen(s)
    if handle == nil then
        return ""
    end
    local result = handle:read("*a")
    handle:close()
    return result
end

local diff = function(opts)
    local records = shell('git log --pretty=format:"%h %an %ar %s"'):gmatch("[^\r\n]+")

    local es = {}
    local max = 0

    for s in records do
        es[#es + 1] = s
        max = math.max(max, #s)
    end

    if opts == nil then
        opts = {}
    end
    opts.previewer = false
    opts.layout_config = {
        height = math.min(#es + 4, vim.o.lines - 8),
        width = math.min(max + 8, vim.o.columns - 8)
    }
    pickers.new(opts, {
        prompt_title = "git commits",
        finder = finders.new_table {
            results = es
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local s = action_state.get_selected_entry()
                if s == nil then
                    return
                end
                -- commit hash
                local h = s[1]:match("^[0-9a-fA-F]+")
                vim.api.nvim_command(string.format(
                "DiffviewOpen %s..HEAD", h
                ))
            end)
            return true
        end,
    }):find()
end

local fns = {
    isDir = function(s)
        local fd = vim.loop.fs_open(s, "r", 438)
        if fd == nil then return false end
        local stat = assert(vim.loop.fs_fstat(fd))
        vim.loop.fs_close(fd)
        return stat.type == "directory"
    end,

    shell = shell,

    diff = diff,
    gerrit = function(opts)
        local result = shell("git review -l -r origin")

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
                    if selection == nil then
                        return
                    end
                    local change = string.match(selection[1], '%d*')
                    os.execute('git review -d ' .. change .. ' -r origin')
                    local o, _ = pcall(require, "nvim-tree")
                    if o then
                        vim.cmd("NvimTreeRefresh")
                    end
                end)
                return true
            end,
        }):find()
    end

}
function Sal(s)
    local fn = fns[s]
    if fn ~= nil then
        fn()
    end
end

return fns
