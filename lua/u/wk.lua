-- disable netrw
vim.api.nvim_exec([[
    let g:loaded_netrw=1
    let g:loaded_netrwPlugin=1
    au VimEnter * :lua Sal("vim-enter")
    au FileType * :lua Sal("buf-new")
]], false)

local sal = require("u.sal")
local tt = require('telescope.themes')
local actions = require "telescope.actions"
local fns = require("u.telescope")

local isDir = function(s)
    local fd = vim.loop.fs_open(s, "r", 438)
    if fd == nil then return false end
    local stat = assert(vim.loop.fs_fstat(fd))
    vim.loop.fs_close(fd)
    return stat.type == "directory"
end

sal["vim-enter"] = function()
    local timer = vim.loop.new_timer()
    local buf = vim.fn.expand('%:p')

    -- open a file, do nothing
    if #buf > 0 and not isDir(buf) then
        return
    end

    if #buf == 0 then
        buf = vim.fn.getcwd()
    end

    -- change current working directory
    vim.api.nvim_command(string.format("cd %s", buf))

    local tree = function()
        timer:start(0, 0, vim.schedule_wrap(function()
            vim.api.nvim_command "NvimTreeOpen"
        end))
    end

    local ok, m = pcall(require, "session_manager.utils")

    -- try to load session
    if ok then
        local name = m.dir_to_session_filename(buf)
        if name:exists() then
            m.load_session(name.filename)
            tree()
            return
        end
    end

    m.is_session = true
    -- if alpha is not active, open
    if vim.bo.filetype ~= "alpha" then
        vim.api.nvim_command "Alpha"
    end

    tree()
end

local ok, wk = pcall(require, "which-key")
if not ok then
    print("which-key not installed")
    return
end

wk.setup({})

local alphas = (function()
    local chars = "123456789"
    for i = 0, 25 do
        chars = chars .. string.char(i + 97)
    end

    for i = 0, 25 do
        chars = chars .. string.char(i + 65)
    end
    return chars
end)()


local reg = function(tb, wkTb)
    local max = 0

    for _, v in ipairs(tb) do
        if #v.group > max then
            max = #v.group
        end
    end

    for _, v in ipairs(tb) do
        local desc = v.group .. ":" .. string.rep(" ", max - #v.group + 1, "") .. v.desc
        wkTb[v.key] = { v.fn, desc }
    end

    wk.register(wkTb, { buffer = 0 })
end

-- generate random keymaps
local nvimTree = function()
    local i = 1
    local mp = vim.api.nvim_buf_set_keymap
    local maps =
    {
        { desc = "cd in directory(C-])", fn = "<C-]>" },
        { desc = "toggle git ignored(I)", fn = "I" },
        { desc = "toggle dot files(H)", fn = "H" },
        { desc = "cut (x)", fn = "x" },
        { desc = "copy (c)", fn = "c" },
        { desc = "paste (p)", fn = "p" },
        { desc = "copy name (y)", fn = "y" },
        { desc = "copy path (Y)", fn = "Y" },
        { desc = "copy absolute path (gy)", fn = "gy" },
        { desc = "collapse all(W)", fn = "W" },
        { desc = "toggle file info(C-k)", fn = "<C-k>" },
    }

    for _, v in ipairs(maps) do
        local key = "<leader><space>" .. alphas:sub(i, i)
        mp(0, "n", key, v.fn, { noremap = false, silent = true, desc = v.desc })
        i = i + 1
    end

    mp(0, "n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { noremap = true, silent = true, desc = "toggle tree" })
    vim.api.nvim_command "messages"
end

local doMap = function()
    if vim.bo.filetype == "NvimTree" then
        nvimTree()
        return
    end

    local i = 1
    local maps = {}
    local helps = {}
    local fs = fns()

    for _, v in ipairs(fs) do
        if v.key == nil then
            v.key = "<leader><space>" .. alphas:sub(i, i)
            i = i + 1
            helps[#helps + 1] = v
        else
            maps[#maps + 1] = v
        end
    end


    local showHelps = function(opts)
        local pickers = require "telescope.pickers"
        local finders = require "telescope.finders"
        local conf = require("telescope.config").values
        local action_state = require "telescope.actions.state"

        local max = 0
        for _, v in ipairs(helps) do
            if #v.group > max then
                max = #v.group
            end
        end

        pickers.new(opts, {
            prompt_title = "helps",
            finder = finders.new_table {
                results = helps,
                entry_maker = function(entry)
                    local pad = max - #entry.group
                    local txt = entry.group .. ': ' .. string.rep(' ', pad) .. entry.desc
                    return {
                        value = entry,
                        display = txt,
                        ordinal = txt,
                    }
                end,
            },
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if selection == nil then
                        return
                    end

                    selection.value.fn()
                end)
                return true
            end,
        }):find()
    end

    maps[#maps + 1] = {
        key = "gh",
        fn = function() showHelps(tt.get_dropdown({
                previewer = false,
                layout_config = {
                    -- display as more items as possible
                    height = math.min(#helps + 4, vim.o.lines - 8),
                }
            }))
        end,
        group = "Finder", desc = "helps",
    }

    reg(maps, {})
    reg(helps, { ["<leader><space>"] = { name = "+helps" } })
end

sal["buf-new"] = doMap
