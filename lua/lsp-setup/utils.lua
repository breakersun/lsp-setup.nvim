local M = {}

function M.mappings(bufnr, mappings)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local opts = { noremap = true, silent = true }
    for key, cmd in pairs(mappings or {}) do
        buf_set_keymap('n', key, '<cmd>' .. cmd .. '<CR>', opts)
    end
end

function M.default_mappings(bufnr, mappings)
    local defaults = {
        gD = 'lua vim.lsp.buf.declaration()',
        gd = 'lua vim.lsp.buf.definition()',
        gi = 'lua vim.lsp.buf.implementation()',
        gr = 'lua vim.lsp.buf.references()',
        K = 'lua vim.lsp.buf.hover()',
        ['<C-k>'] = 'lua vim.lsp.buf.signature_help()',
        ['<space>rn'] = 'lua vim.lsp.buf.rename()',
        ['<space>ca'] = 'lua vim.lsp.buf.code_action()',
        ['<space>f'] = 'lua vim.lsp.buf.formatting()', -- compatible with nvim-0.7
        ['<space>e'] = 'lua vim.diagnostic.open_float()',
        ['[d'] = 'lua vim.diagnostic.goto_prev()',
        [']d'] = 'lua vim.diagnostic.goto_next()',
    }
    mappings = vim.tbl_deep_extend('keep', mappings or {}, defaults)
    M.mappings(bufnr, mappings)
end

function M.disable_formatting(client)
    if vim.fn.has('nvim-0.8') == 1 then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    else
        client.server_capabilities.document_formatting = false
        client.server_capabilities.document_range_formatting = false
    end
end

function M.format_on_save(client)
    if client.supports_method('textDocument/formatting') then
        local lsp_format_augroup = vim.api.nvim_create_augroup('LspFormat', { clear = true })
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = lsp_format_augroup,
            callback = function()
                if vim.fn.has('nvim-0.8') == 1 then
                    vim.lsp.buf.format()
                else
                    vim.lsp.buf.formatting_sync({}, 1000)
                end
            end,
        })
    end
end

return M
