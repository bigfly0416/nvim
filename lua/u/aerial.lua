local ok, a = pcall(require, "aerial")

if not ok then
    return
end

local b = require("aerial.bindings").keys
local p

for _, v in ipairs(b) do
    if type(v[1]) == "string" and v[1] == "p" then
        p = v
    end
end

for _, v in ipairs(b) do
    if type(v[1]) == "table" and v[1][1] == "l" then
        v[1] = { "zo" }
        b[#b + 1] = { "l", p[2], p[3] }
    end

    if type(v[1]) == "string" and v[1] == "<CR>" then
        v[2] = p[2]
        v[3] = p[3]
    end
end

a.setup({})
