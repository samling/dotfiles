return {
  'alexghergh/nvim-tmux-navigation',
  config = function()
    local nvim_tmux_nav = require 'nvim-tmux-navigation'
    nvim_tmux_nav.setup {
      disable_when_zoomed = true, -- defaults to false
      vim.keymap.set('n', '<C-h>', nvim_tmux_nav.NvimTmuxNavigateLeft, { desc = 'Navigate buffers left' }),
      vim.keymap.set('n', '<C-j>', nvim_tmux_nav.NvimTmuxNavigateDown, { desc = 'Navigate buffers down' }),
      vim.keymap.set('n', '<C-k>', nvim_tmux_nav.NvimTmuxNavigateUp, { desc = 'Navigate buffers up' }),
      vim.keymap.set('n', '<C-l>', nvim_tmux_nav.NvimTmuxNavigateRight, { desc = 'Navigate buffers right' }),
      vim.keymap.set('n', '<C-\\>', nvim_tmux_nav.NvimTmuxNavigateLastActive, { desc = 'Move to last active buffer' }),
      vim.keymap.set('n', '<C-\\>', nvim_tmux_nav.NvimTmuxNavigateNext, { desc = 'Move to next buffer' }),
    }
  end,
}
