-- Fix common typos
vim.cmd [[
    cnoreabbrev W! w!
    cnoreabbrev W1 w!
    cnoreabbrev w1 w!
    cnoreabbrev Q! q!
    cnoreabbrev Q1 q!
    cnoreabbrev q1 q!
    cnoreabbrev Qa! qa!
    cnoreabbrev Qall! qall!
    cnoreabbrev Wa wa
    cnoreabbrev Wq wq
    cnoreabbrev wQ wq
    cnoreabbrev WQ wq
    cnoreabbrev wq1 wq!
    cnoreabbrev Wq1 wq!
    cnoreabbrev wQ1 wq!
    cnoreabbrev WQ1 wq!
    cnoreabbrev W w
    cnoreabbrev Q q
    cnoreabbrev Qa qa
    cnoreabbrev Qall qall
]]

-- Clear search highlight on pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic error messages' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix list' })

-- If moving up and down lines with j and k, remap to gj/gk in order to move up and down relative lines (i.e. consider a wrapped line a new line). If using j/k with a count, function normally
vim.keymap.set({ 'n', 'x' }, 'j', function()
  return vim.v.count > 0 and 'j' or 'gj'
end, { noremap = true, expr = true })
vim.keymap.set({ 'n', 'x' }, 'k', function()
  return vim.v.count > 0 and 'k' or 'gk'
end, { noremap = true, expr = true })

-- Go to beginning and end of lines with gh and gl
vim.keymap.set('n', 'gh', '^')
vim.keymap.set('n', 'gl', '$')
vim.keymap.set('n', 'H', '^')
vim.keymap.set('n', 'L', '$')

-- Buffers
vim.keymap.set('n', '<leader>bb', function()
  local builtin = require 'telescope.builtin'
  builtin.buffers { sort_mru = true, ignore_current_buffer = false }
end, { desc = 'Current buffers' })
vim.keymap.set('n', '<leader>b', '<nop>', { desc = 'Buffers' })
vim.keymap.set('n', '<leader>bN', ':enew<CR>', { desc = 'Create a new buffer' })
vim.keymap.set('n', '<leader>bp', ':bprev<CR>', { desc = 'Move to the previous buffer' })
vim.keymap.set('n', '[b', ':bprev<CR>', { desc = 'Move to the previous buffer' })
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Move to the next buffer' })
vim.keymap.set('n', ']b', ':bnext<CR>', { desc = 'Move to the next buffer' })
vim.keymap.set('n', '<leader>bx', '<C-W><C-S>', { desc = 'Split the current buffer horizontally' })
vim.keymap.set('n', '<leader>by', '<C-W><C-V>', { desc = 'Split the current buffer vertically' })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Close the current buffer' })
vim.keymap.set('n', '<leader>bq', ':bdelete<CR>', { desc = 'Close the current buffer' })
vim.keymap.set('n', '<leader>bw', ':bdelete<CR>', { desc = 'Close the current buffer' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
--
-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
-- vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
-- vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
