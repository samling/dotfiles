return {
  'saghen/blink.cmp',
  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      -- super-tab defaults
      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide', 'fallback' },

      ['<Tab>'] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          else
            return cmp.select_and_accept()
          end
        end,
        'snippet_forward',
        'fallback',
      },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
      ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

      ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

      ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },

      -- custom
      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' }
    },
    appearance = {
      nerd_font_variant = 'mono',
    },
    cmdline = {
      enabled = true,
      keymap = {
        -- optionally, inherit the mappings from the top level `keymap`
        -- instead of using the neovim defaults
        -- preset = 'inherit',
        preset = 'cmdline',
      },
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = {
      ghost_text = {
        enabled = true,
      },
      documentation = {
        auto_show = true,
        window = {
          border = 'rounded',
        },
      },
      menu = {
        border = 'rounded',
        draw = {
          padding = 0,
          columns = { { 'kind_icon', gap = 1 }, { gap = 1, 'label' }, { 'kind', gap = 2 } },
          components = {
            kind_icon = {
              text = function(ctx)
                return ' ' .. ctx.kind_icon .. ' '
              end,
              highlight = function(ctx)
                return 'BlinkCmpKindIcon' .. ctx.kind
              end,
            },
            kind = {
              text = function(ctx)
                return ' ' .. ctx.kind .. ' '
              end,
            },
          },
        },
      },
      list = {
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },
      trigger = {
        show_on_trigger_character = true,
      },
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
  opts_extend = { 'sources.default' },
}
