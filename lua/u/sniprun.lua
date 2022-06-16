local ok, s = pcall(require, "sniprun")
if not ok then
    return
end

s.setup({})
