local ok, toggleterm = pcall(require, "toggleterm")
if not ok then
    return
end

toggleterm.setup({
    size = 20,
    open_mapping = [[<C-\>]],
    on_open = function()
        vim.cmd [[echo 'term =' b:toggle_number]]
    end,
    shading_factor = 2,
    direction = "float",
    float_opts = {
        border = "curved",
        width = function() return vim.o.columns - 8 end,
        height = function() return vim.o.lines - 8 end,
        winblend = 0,
        highlights = {
            border = "Normal",
            background = "Normal",
        },
    },
})

