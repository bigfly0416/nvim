local ok, gs, df
ok, gs = pcall(require, "gitsigns")

if not ok then
    print("gitsigns not installed")
    return
end

gs.setup({})


ok, df = pcall(require, "diffview")
if not ok then
    return
end

local actions = require("diffview.actions")

df.setup({
    keymaps = {
        view = {
            ["<leader>e"] = actions.toggle_files,
        },
        file_panel = {
            l             = actions.select_entry,
            ["<leader>e"] = actions.toggle_files,
        },
        file_history_panel = {
            l = actions.select_entry,
            ["<leader>e"] = actions.toggle_files,
        }
    }
})
