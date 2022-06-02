local ok, dap, ui, vt

ok, dap = pcall(require, "dap")

if not ok then
    print("dap not installed")
    return
end


ok, ui = pcall(require, "dapui")

if not ok then
    print("dapui not installed")
    return
end

ui.setup({
    sidebar = {
        position = "right"
    }
})



ok, vt = pcall(require, "nvim-dap-virtual-text")

if not ok then
    print("nvim-dap-virtual-text not installed")
    return
end

vt.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
    ui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    ui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    ui.close()
end

require("u.dap.go")

vim.g["test#go#gotest#options"] = "-v"
vim.g["ultest_summary_mappings"] = {
    jumpto = "l"
}

ok, ul = pcall(require, "ultest")

if not ok then
    print("vim-ultest not installed")
    return
end

ul.setup(
    {
    builders = {
        ["go#gotest"] = function(cmd)
            local args = {}
            for i = 3, #cmd - 1, 1 do
                local arg = cmd[i]
                if vim.startswith(arg, "-") then
                    -- Delve requires test flags be prefix with 'test.'
                    arg = "-test." .. string.sub(arg, 2)
                end
                args[#args + 1] = arg
            end
            return {
                dap = {
                    type = "go",
                    request = "launch",
                    mode = "test",
                    program = string.match(vim.fn.expand("%"), "(.*[/\\])"),
                    dlvToolPath = vim.fn.exepath("dlv"),
                    args = args
                },
                parse_result = function(lines)
                    return lines[#lines] == "FAIL" and 1 or 0
                end
            }
        end
    }
}
)
