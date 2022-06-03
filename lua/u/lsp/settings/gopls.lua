local opts = {
    on_attach = function(c, _)
        c.resolved_capabilities.document_formatting = false
        c.resolved_capabilities.document_range_formatting = false
    end
}
return opts
