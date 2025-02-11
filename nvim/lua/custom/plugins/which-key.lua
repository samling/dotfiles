local M = {
  'folke/which-key.nvim',
  -- "VeryLazy" hides splash screen
  event = 'BufReadPost',
}

M.init = function()
  vim.o.timeout = true
  vim.o.timeoutlen = 300
end

return M

-- M.init = function()
--   vim.o.timeout = true
--   vim.o.timeoutlen = 300
-- end
--
-- M.config = function()
--   vim.keymap.set('v', '<leader>?', "<Esc>:WhichKey '' v<CR>", { silent = true })
--   vim.keymap.set('n', '<leader>?', "<Esc>:WhichKey '' n<CR>", { silent = true, desc = 'which-key root' })
--
--   -- Diagnostics
--   vim.keymap.set('', '<leader>d', '<cmd> lua vim.diagnostic.open_float() <CR>', { desc = 'Opens floating window with full diagnostics'})
--
--
--   -- https://github.com/folke/which-key.nvim#colors
--   vim.cmd [[highlight default link WhichKey          Label]]
--   vim.cmd [[highlight default link WhichKeySeperator String]]
--   vim.cmd [[highlight default link WhichKeyGroup     Include]]
--   vim.cmd [[highlight default link WhichKeyDesc      Function]]
--   vim.cmd [[highlight default link WhichKeyFloat     CursorLine]]
--   vim.cmd [[highlight default link WhichKeyValue     Comment]]
--
--   local wk = require 'which-key'
--   wk.setup {
--     plugins = {
--       marks = true, -- shows a list of marks on ' and `
--       registers = false, -- shows registers on " in NORMAL or <C-r> in INSERT mode
--       -- the presets plugin adds help for a bunch of default keybindings in nvim
--       -- no actual keybindings are created
--       spelling = {
--         enabled = true, -- show which-key when pressing z= to spell suggest
--         suggestions = 20, -- how many suggestions to show
--       },
--       presets = {
--         operators = false, -- adds help for operators like d, y, ...
--         motions = false, -- adds help for motions
--         text_objects = false, -- help for text objects triggered when entering an operator
--         windows = true, -- default bindings on <c-w>
--         nav = true, -- misc bindings to work with windows
--         z = true, -- bindings for folds, spelling and others prefixed with z
--         g = true, -- bindings prefixed with g
--       },
--     },
--     -- add operators taht will trigger motion and text object completion
--     -- to enable all native operators, set the preset / operators plugin above
--     defer = { gc = 'Comments' },
--     replace = {
--       -- override the label used to display some keys
--       ['<space>'] = 'SPC',
--       ['<cr>'] = 'RET',
--       ['<tab>'] = 'TAB',
--     },
--     icons = {
--       breadcrumb = '»', -- symbol used in command line area that shows active key combo
--       separator = '➜', -- symbol used between a key and its label
--       group = '+', -- symbol prepended to a group
--     },
--     win = {
--       border = 'none', -- none, single, double, window
--       position = 'bottom', -- bottom, top
--       margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
--       padding = { 1, 1, 1, 1 }, -- extra window padding [top, right, bottom, left]
--     },
--     layout = {
--       height = { min = 4, max = 25 }, -- min and max height of columns
--       width = { min = 20, max = 50 }, -- min and max width of columns
--       spacing = 5, -- spacing between columns
--     },
--     -- hide mapping boilerplate
--     -- hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ' },
--     show_help = true, -- show help message on the command line when popup is visible
--     -- triggers = 'auto', -- automatically set up triggers
--     -- triggers = {"<leader>"} -- or specify a list manually
--   }
--
--   local opts = {
--     mode = 'n', -- NORMAL, VISUAL mode
--     buffer = nil, -- global mappings. specify a buffer number for buffer local mappings
--     silent = true, -- use `silent` when creating keymaps
--     noremap = true, -- use `noremap` when creating keymaps
--     nowait = true, -- use `nowait` when creating keymaps
--   }
--
-- --   local keymaps = {
-- --       { "<leader>", group = "fold", nowait = true, remap = false },
-- --       { "<leader>", group = "noice", nowait = true, remap = false },
-- --       { "<leader>", group = "definitions", nowait = true, remap = false },
-- --       { "<leader>", group = "buffers", nowait = true, remap = false },
-- --       { "<leader>", group = "quit/session", nowait = true, remap = false },
-- --       { "<leader>", group = "prev", nowait = true, remap = false },
-- --       { "<leader>", group = "search with telescope", nowait = true, remap = false },
-- --       { "<leader>", group = "next", nowait = true, remap = false },
-- --       { "<leader>", group = "goto", nowait = true, remap = false },
-- --       { "<leader>", group = "leader", nowait = true, remap = false },
-- --       { "<leader>", group = "surround", nowait = true, remap = false },
-- --       { "[", group = "prev", nowait = true, remap = false },
-- --       { "]", group = "next", nowait = true, remap = false },
-- --       { "g", group = "goto", nowait = true, remap = false },
-- --       { "s", group = "surround", nowait = true, remap = false },
-- --       { "z", group = "fold", nowait = true, remap = false },
-- --       { "<leader>", group = "harpoon", mode = { "n", "v" }, nowait = true, remap = false },
-- --       { "<leader>", group = "replace with spectre", mode = { "n", "v" }, nowait = true, remap = false },
-- -- }
--
--   wk.register(keymaps, opts)
-- end
--
-- return M
