-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/noice.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/noice.lua

-- I want to change the default notifications to be less obtrussive (if that's even a word)
-- https://github.com/folke/noice.nvim

return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = function()
      local wk = require("which-key")
        wk.add({
          { "<leader>n", group = "Noice" }
        })

        vim.keymap.set("n", "<leader>nl", function()
          require("noice").cmd("last")
        end, { desc = 'Last' })

        vim.keymap.set("n", "<leader>nh", function()
          require("noice").cmd("history")
        end, { desc = 'History' })

      return {
        presets = {
          -- This is the search bar or popup that shows up when you press /
          -- Setting this to false makes it a popup and true the search bar at the bottom
          -- search middle
          bottom_search = false,
          lsp_doc_border = true,
        },
        messages = {
          -- NOTE: If you enable messages, then the cmdline is enabled automatically.
          -- This is a current Neovim limitation.
          enabled = true, -- enables the Noice messages UI
          view = "mini", -- default view for messages
          view_error = "mini", -- view for errors
          view_warn = "mini", -- view for warnings
          view_history = "mini", -- view for :messages
          view_search = "mini", -- view for search count messages. Set to `false` to disable
        },
        notify = {
          -- Noice can be used as `vim.notify` so you can route any notification like other messages
          -- Notification messages have their level and other properties set.
          -- event is always "notify" and kind can be any log level as a string
          -- The default routes will forward notifications to nvim-notify
          -- Benefit of using Noice for this is the routing and consistent history view
          enabled = true,
          view = "mini",
        },
        lsp = {
          message = {
            -- Messages shown by lsp servers
            enabled = true,
            view = "mini",
          },
        },
        views = {
          -- This sets the position for the search popup that shows up with / or with :
          cmdline_popup = {
            position = {
              row = 5,
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto"
            }
          },
          popupmenu = {
            relative = "editor",
            position = {
              row = 8,
              col = "50%",
            },
            size = {
              width = 60,
              height = 10,
            },
            border = {
              style = 'rounded',
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
            }
          },
          mini = {
            -- timeout = 5000, -- timeout in milliseconds
            timeout = vim.g.neovim_mode == "skitty" and 2000 or 5000,
            align = "center",
            position = {
              -- Centers messages top to bottom
              row = "95%",
              -- Aligns messages to the far right
              col = "100%",
            },
          },
        },
      }
      end
    }
  }
