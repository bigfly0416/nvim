local fns = {

}
function Sal(s)
    local fn = fns[s]
    if fn ~= nil then
        fn()
    end
end

return fns
