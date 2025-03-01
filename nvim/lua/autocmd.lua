-- -- [[ Basic Autocommands ]]
-- --  See :help lua-guide-autocommands
--
-- -- clipboard loading
local is_wsl = vim.fn.has "wsl"
local is_windows = vim.fn.has "win32" or vim.fn.has "win64"
local is_mac = vim.fn.has "macunix"
local is_unix = vim.fn.has "unix"

vim.api.nvim_create_autocmd({ "BufNew", "BufReadPost", "BufNewFile" }, {
  once = true,
  callback = function()
    if is_windows == 1 and not is_wsl == 1 then
      print "Using Windows clipboard."
      vim.g.clipboard = {
        copy = {
          ["+"] = "win32yank.exe -i --crlf",
          ["*"] = "win32yank.exe -i --crlf",
        },
        paste = {
          ["+"] = "win32yank.exe -o --lf",
          ["*"] = "win32yank.exe -o --lf",
        },
        cache_enabled = 0,
      }
    elseif is_mac == 1 then
      print "Using Mac clipboard."
      vim.g.clipboard = {
        copy = {
          ["+"] = "pbcopy",
          ["*"] = "pbcopy",
        },
        paste = {
          ["+"] = "pbpaste",
          ["*"] = "pbpaste",
        },
        cache_enabled = 0,
      }
    elseif is_unix == 1 or is_wsl == 1 then
      print "Using Linux clipboard."
      if vim.fn.executable "wl-copy" == 1 then
        vim.g.clipboard = {
          copy = {
            ["+"] = "wl-copy",
            ["*"] = "wl-copy",
          },
          paste = {
            ["+"] = "wl-paste",
            ["*"] = "wl-paste",
          },
          cache_enabled = 0,
        }
      elseif vim.fn.executable "xclip" == 1 then
        vim.g.clipboard = {
          copy = {
            ["+"] = "xclip -selection clipboard",
            ["*"] = "xclip -selection clipboard",
          },
          paste = {
            ["+"] = "xclip -selection clipboard -o",
            ["*"] = "xclip -selection clipboard -o",
          },
          cache_enabled = 0,
        }
      elseif vim.fn.executable "xsel" == 1 then
        vim.g.clipboard = {
          copy = {
            ["+"] = "xsel --clipboard --input",
            ["*"] = "xsel --clipboard --input",
          },
          paste = {
            ["+"] = "xsel --clipboard --output",
            ["*"] = "xsel --clipboard --output",
          },
          cache_enabled = 0,
        }
      end
    end

    vim.opt.clipboard = "unnamedplus"
  end,
  desc = "Lazy load clipboard",
})
--
-- -- Highlight when yanking (copying) text
-- --  Try it with `yap` in normal mode
-- --  See `:help vim.highlight.on_yank()`
-- vim.api.nvim_create_autocmd('TextYankPost', {
--   desc = 'Highlight when yanking (copying) text',
--   group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
--   callback = function()
--     vim.highlight.on_yank()
--   end,
-- })
