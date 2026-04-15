local M = {
  'numToStr/Comment.nvim',
  event = 'VeryLazy',
}

M.config = function()
  require('Comment').setup {
    padding = true, -- add a space between comment and line
    sticky = true, -- keep cursor at current position

    mappings = {
      basic = true, -- includes `gcc`, `gbc`, `gc[count]{motion}` and `gb[count]{motion}`
      extra = true, -- includes `gco`, `gc0`, `gcA`
      extended = false, -- includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
    },

    toggler = {
      line = 'gcc', -- line-comment toggle keymap
      block = 'gbc', -- block-comment toggle keymap
    },

    opleader = {
      line = 'gc', -- line-comment keymap
      block = 'gb', -- block-comment keymap
    },
  }
end

return M
