local ok, tree = pcall(require, 'nvim-tree')

if not ok then
    print("nvim-tree not installed")
    return
end

local defaultSize = 20

local custom = function(opts)
    return {
        hijack_netrw = false,
        open_on_setup = false,
        diagnostics = {
            enable = true,
            show_on_dirs = true,
        },
        git = {
            enable = true,
            ignore = false,
        },
        view = {
            width = defaultSize,
            mappings = {
                list = {
                    { key = { "l", "<CR>", "o" }, action = "edit" },
                    { key = "h", action = "close_node" },
                },
            },
        },
        ignore_ft_on_setup = { "alpha" },
        actions = {
            change_dir = {
                enable = false
            },
            open_file = {
                resize_window = false
            }
        },
        renderer = {
            icons = {
                glyphs = {
                    default = "",
                    symlink = "",
                    git = {
                        unstaged = "",
                        staged = "",
                        unmerged = "",
                        renamed = "➜",
                        deleted = "",
                        untracked = "◍",
                        ignored = "◌",
                    },
                    folder = {
                        default = "",
                        open = "",
                        empty = "",
                        empty_open = "",
                        symlink = "",
                    },
                }
            }
        }
    }
end

tree.setup(custom({}))
