return {
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  event = 'LspAttach',
  config = function()
    local lsp_lines = require 'lsp_lines'
    lsp_lines.setup()

    -- Disable default virtual_lines diagnostics in favor of lua_lines
    vim.diagnostic.config { virtual_text = false }

    -- https://todo.sr.ht/~whynothugo/lsp_lines.nvim/40#event-242660
    lsp_lines.toggle()
    local previously = not lsp_lines.toggle()

    local group = vim.api.nvim_create_augroup('LspLinesToggleInsert', { clear = false })
    vim.api.nvim_create_autocmd('InsertEnter', {
      group = group,
      callback = function()
        previously = not lsp_lines.toggle()
        if not previously then
          lsp_lines.toggle()
        end
      end,
    })

    vim.api.nvim_create_autocmd('InsertLeave', {
      group = group,
      callback = function()
        if lsp_lines.toggle() ~= previously then
          lsp_lines.toggle()
        end
      end,
    })
  end,
  keys = function()
    vim.keymap.set('', '<leader>l', require('lsp_lines').toggle, { remap = true, desc = 'Toggle lsp_lines' })
  end,
}
