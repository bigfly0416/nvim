local ok, ins, cmp_nvim_lsp
ok, _ = pcall(require, "lspconfig")
if not ok then
    print("lspconfig not installed")
    return
end

ok, ins = pcall(require, "nvim-lsp-installer")

if not ok then
    print("lsp installer not installed")
    return
end

-- setup lsp diagnostic
require "u.lsp.signs"

-- setup lsp installer, lazy load language server
local on_attach = function(client, bufnr)
    local mp = vim.api.nvim_buf_set_keymap
    local keys = require("u.lsp.keys")

    for name, v in pairs(keys) do
        local opts = { noremap = true, silent = true, desc = name }
        mp(bufnr, "n", v[1], string.format('<cmd>lua require("u.lsp.keys")["%s"][2]()<cr>', name), opts)
    end

    -- Set autocommands conditional on server_capabilities
    if client.resolved_capabilities.document_highlight then
        vim.cmd
            [[
              augroup lsp_document_highlight
                autocmd! * <buffer>
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
              augroup END
            ]]
    end
end

-- setup capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
    capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
else
    print("cmp_nvim_lsp not installed")
end


ins.on_server_ready(
    function(s)
    local o, opts = pcall(require, "u.lsp.settings." .. s.name)
    if not o then
        opts = {}
    end

    local fn = on_attach
    if opts.on_attach then
        local sub = opts.on_attach
        fn = function(c, b)
            sub(c, b)
            on_attach(c, b)
        end
    end
    opts.on_attach = fn
    opts.capabilities = capabilities
    s:setup(opts)
end
)

-- setup null-ls
require "u.lsp.nl"
