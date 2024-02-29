return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
  opts = function()
    local logo = 'Welcome to NVIM'

    local opts = {
      theme = 'doom',
      hide = {
        -- taken care of by lualine
        statusline = false,
      },
      config = {
        header = vim.split(logo, '\n'),
        center = {
          { action = 'Telescope find_files', desc = ' Find file', icon = ' ', key = 'f' },
          { action = 'ene | startinsert', desc = ' New file', icon = ' ', key = 'n' },
          { action = 'Telescope oldfiles', desc = ' Recent files', icon = ' ', key = 'r' },
          { action = 'Telescope live_grep', desc = ' Find text', icon = ' ', key = 'g' },
          { action = [[lua require("lazyvim.util").telescope.config_files()()]], desc = ' Config', icon = ' ', key = 'c' },
          { action = 'lua require("persistence").load()', desc = ' Restore Session', icon = ' ', key = 's' },
          { action = 'LazyExtras', desc = ' Lazy Extras', icon = ' ', key = 'x' },
          { action = 'Lazy', desc = ' Lazy', icon = '󰒲 ', key = 'l' },
          { action = 'qa', desc = ' Quit', icon = ' ', key = 'q' },
        },
      },
    }
    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(' ', 43 - #button.desc)
      button.key_format = ' %s'
    end

    if vim.o.filetype == 'lazy' then
      vim.cmd.close()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'DashboardLoaded',
        callback = function()
          require('lazy').show()
        end,
      })
    end

    return opts
  end,
}
