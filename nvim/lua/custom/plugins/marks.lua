local M = {
  'chentoast/marks.nvim',
}

M.config = function()
  local m = require 'marks'
  m.setup {
    default_mappings = true,
    builtin_marks = { '.', '<', '>', '^' },
    cyclic = true, -- cycle movements back to beginning of buffer
    force_write_shada = false, -- don't force shada file update after modifying uppercase marks
    refresh_interval = 250, -- refresh in ms
  }
end

return M
