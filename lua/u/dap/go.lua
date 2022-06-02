local ok, dap

ok, dap = pcall(require, "dap")

if not ok then
    print("dap not installed")
    return
end

dap.adapters.go = {
    type = 'executable';
    command = 'node';
    args = { '--no-deprecation', '/Volumes/dev/Github/vscode-go/dist/debugAdapter.js' };
}
