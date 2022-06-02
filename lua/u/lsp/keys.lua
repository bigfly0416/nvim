local ok, tb = pcall(require, "telescope.builtin")
if not ok then
    print("telescope not installed")
end


-- lsp 针对不同类型的文件 lsp 的 key 要单独配置
-- 使用描述字符串作为入参数
return {
    ["LSP code actions"] = { "ga", function() tb.lsp_code_actions() end },
    ["LSP references"] = { "gr", function()
        tb.lsp_references(
            { includeDeclaration = false, layout_config = { width = 0.99 } }
        )
    end },
    ["LSP definitions"] = { "gd", function()
        tb.lsp_definitions({ layout_config = { width = 0.99 } })
    end },
    ["LSP type definitions"] = { "gt", function()
        tb.lsp_type_definitions()
    end },
    ["LSP implementations"] = { "gi", function()
        tb.lsp_implementations({ layout_config = { width = 0.99 } })
    end },
    ["LSP diagnostics"] = { "gL", function()
        tb.diagnostics({ bufnr = 0, layout_config = { width = 0.99 } })
    end },
    ["LSP format buf"] = { "=", function()
        vim.lsp.buf.formatting()
    end },
    ["LSP hover"] = { "K", function()
        vim.lsp.buf.hover()
    end },
    ["LSP rename symbol"] = { "gn", function()
        vim.lsp.buf.rename()
    end },
    ["LSP diagnostic"] = { "gl", function()
        vim.diagnostic.open_float({ border = "rounded" })
    end },
}
