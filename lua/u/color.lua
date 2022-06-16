local ok, c = pcall(require, "colorizer")

if not ok then
    print("colorizer not installed")
    return
end

c.setup({})
