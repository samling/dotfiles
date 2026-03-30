return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    local C = require('catppuccin.palettes').get_palette 'mocha'

    require('bufferline').setup {
      highlights = {
        fill = { bg = C.crust },
        background = { bg = C.base, fg = C.overlay0 },
        buffer_visible = { bg = C.base, fg = C.overlay0 },
        buffer_selected = { bg = C.mantle, fg = C.text, bold = true },
        close_button = { bg = C.base, fg = C.overlay0 },
        close_button_visible = { bg = C.base, fg = C.overlay0 },
        close_button_selected = { bg = C.mantle, fg = C.text },
        separator = { bg = C.base, fg = C.crust },
        separator_visible = { bg = C.base, fg = C.crust },
        separator_selected = { bg = C.mantle, fg = C.crust },
        modified = { bg = C.base, fg = C.peach },
        modified_visible = { bg = C.base, fg = C.peach },
        modified_selected = { bg = C.mantle, fg = C.peach },
        duplicate = { bg = C.base, fg = C.overlay0, italic = true },
        duplicate_visible = { bg = C.base, fg = C.overlay0, italic = true },
        duplicate_selected = { bg = C.mantle, fg = C.text, italic = true },
        diagnostic = { bg = C.base },
        diagnostic_visible = { bg = C.base },
        diagnostic_selected = { bg = C.mantle },
        error = { bg = C.base, fg = C.red },
        error_visible = { bg = C.base, fg = C.red },
        error_selected = { bg = C.mantle, fg = C.red },
        error_diagnostic = { bg = C.base, fg = C.red },
        error_diagnostic_visible = { bg = C.base, fg = C.red },
        error_diagnostic_selected = { bg = C.mantle, fg = C.red },
        warning = { bg = C.base, fg = C.yellow },
        warning_visible = { bg = C.base, fg = C.yellow },
        warning_selected = { bg = C.mantle, fg = C.yellow },
        warning_diagnostic = { bg = C.base, fg = C.yellow },
        warning_diagnostic_visible = { bg = C.base, fg = C.yellow },
        warning_diagnostic_selected = { bg = C.mantle, fg = C.yellow },
        indicator_selected = { bg = C.mantle, fg = C.lavender },
        tab = { bg = C.base, fg = C.overlay0 },
        tab_selected = { bg = C.mantle, fg = C.text },
        tab_separator = { bg = C.base, fg = C.crust },
        tab_separator_selected = { bg = C.mantle, fg = C.crust },
      },
      options = {
        separator_style = 'slant',
        indicator = {
          icon = '▎',
          style = 'icon',
        },
        buffer_close_icon = '',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level)
          local icon = level:match 'error' and '' or (level:match 'warning' and '' or '')
          return ' ' .. icon .. ' ' .. count
        end,
        always_show_bufferline = true,
        tab_size = 18,
        max_name_length = 18,
        sort_by = 'extension',
        offsets = {
          {
            filetype = 'neo-tree',
            text = 'File Explorer',
            highlight = 'Directory',
            separator = true,
          },
        },
      },
    }
  end,
}
