local M = {}

M.tmux_aware_navigate = function(direction, no_wrap)
  local curwin = vim.api.nvim_get_current_win()
  -- First attempt to send a wincmd
  vim.cmd.wincmd(direction == '\\' and 'w' or direction)
  if not vim.env.TMUX or vim.api.nvim_get_current_win() ~= curwin then
    -- Stop here if no TMUX or wincmd switched windows
    return
  end
  -- tmux exists and window wasn't switched
  -- forward the command to tmux
  local tmux_pane_flag = {
    ['h'] = '-L',
    ['j'] = '-D',
    ['k'] = '-U',
    ['l'] = '-R',
    ['\\'] = '-l',
  }
  local tmux_pane_to = {
    ['h'] = 'left',
    ['j'] = 'bottom',
    ['k'] = 'top',
    ['l'] = 'right',
  }
  local args = { 'tmux' }
  if no_wrap then
    table.insert(args, 'if-shell')
    table.insert(args, '-F')
    table.insert(args, string.format('#{pane_at_%s}', tmux_pane_to[direction]))
    table.insert(args, '')
    table.insert(args, string.format('select-pane -t %s %s', vim.env.TMUX_PANE, tmux_pane_flag[direction]))
  else
    table.insert(args, 'select-pane')
    table.insert(args, '-t')
    table.insert(args, vim.env.TMUX_PANE)
    table.insert(args, tmux_pane_flag[direction])
  end
  vim.fn.system(args)
end

return M
