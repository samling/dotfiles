-- [[ Basic Autocommands ]]
--  See :help lua-guide-autocommands

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- -- Sync with system clipboard on focus
-- vim.api.nvim_create_autocmd({ "FocusGained" }, {
--   pattern = { "*" },
--   command = [[call setreg("@", getreg("+"))]],
-- })
--
-- -- Sync with system clipboard on focus
-- vim.api.nvim_create_autocmd({ "FocusLost" }, {
--   pattern = { "*" },
--   command = [[call setreg("+", getreg("@"))]],
-- })
