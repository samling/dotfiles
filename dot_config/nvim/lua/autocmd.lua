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
      print "Using Linux clipboard with wl-clipboard."
      if vim.fn.executable "wl-copy" == 1 then
        vim.g.clipboard = {
          copy = {
            ["+"] = "wl-copy",
            ["*"] = "wl-copy",
          },
          paste = {
            ["+"] = "wl-paste -n",
            ["*"] = "wl-paste -n",
          },
          cache_enabled = 0,
        }
      -- elseif vim.fn.executable "xsel" == 1 then
      --   print "Using Linux clipboard with xsel."
      --   vim.g.clipboard = {
      --     copy = {
      --       ["+"] = "xsel --clipboard --input",
      --       ["*"] = "xsel --clipboard --input",
      --     },
      --     paste = {
      --       ["+"] = "xsel --clipboard --output",
      --       ["*"] = "xsel --clipboard --output",
      --     },
      --     cache_enabled = 0,
      --   }
      -- elseif vim.fn.executable "xclip" == 1 then
      --   vim.g.clipboard = {
      --     copy = {
      --       ["+"] = "xclip -selection clipboard",
      --       ["*"] = "xclip -selection clipboard",
      --     },
      --     paste = {
      --       ["+"] = "xclip -selection clipboard -o",
      --       ["*"] = "xclip -selection clipboard -o",
      --     },
      --     cache_enabled = 0,
      --   }
      end
    end

    vim.opt.clipboard = "unnamedplus"
  end,
  desc = "Lazy load clipboard",
})

-- LSP AutoAttach
-- https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(ev)
    local bufmap = function(mode, lhs, rhs)
      local opts = {buffer = true}
      vim.keymap.set(mode, lhs, rhs, opts)

      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client and client:supports_method('textDocument/completion') then
        vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
      end
    end

    -- Displays hover information about the symbol under the cursor
    bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

    -- Jump to the definition
    bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

    -- Jump to declaration
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

    -- Lists all the implementations for the symbol under the cursor
    bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

    -- Jumps to the definition of the type symbol
    bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

    -- Lists all the references 
    bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

    -- Displays a function's signature information
    bufmap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

    -- Renames all references to the symbol under the cursor
    bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

    -- Selects a code action available at the current cursor position
    bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')

    -- Show diagnostics in a floating window
    bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

    -- Move to the previous diagnostic
    bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

    -- Move to the next diagnostic
    bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
  end
})

local function source_matugen()
  -- Update this with the location of your output file
  local matugen_path = os.getenv("HOME") .. "/.config/nvim/generated.lua"  -- dofile doesn't expand $HOME or ~

  local file, err = io.open(matugen_path, "r")
  -- If the matugen file does not exist (yet or at all), we must initialize a color scheme ourselves
  if err ~= nil then
    -- Some placeholder theme, this will be overwritten once matugen kicks in
    vim.cmd('colorscheme base16-catppuccin-mocha')

    -- Optionally print something to the user
    vim.print("A matugen style file was not found, but that's okay! The colorscheme will dynamically change if matugen runs!")
  else
    dofile(matugen_path)
    io.close(file)
  end
end

-- Main entrypoint on matugen reloads
local function auxiliary_function()
  -- Load the matugen style file to get all the new colors
  source_matugen()

  -- Because reloading base16 overwrites lualine configuration, just source lualine here
  dofile(os.getenv("HOME") .. '/.config/nvim/lua/custom/plugins/lualine.lua') -- path of your lualine setup

  -- Any other options you wish to set upon matugen reloads can also go here!
  vim.api.nvim_set_hl(0, "Comment", { italic = true })
end

-- Hot-reload colors from matugen
-- Register an autocmd to listen for matugen updates
vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = auxiliary_function,
})
