local noice = require("noice")

local border = {
  { '┌', 'FloatBorder' },
  { '─', 'FloatBorder' },
  { '┐', 'FloatBorder' },
  { '│', 'FloatBorder' },
  { '┘', 'FloatBorder' },
  { '─', 'FloatBorder' },
  { '└', 'FloatBorder' },
  { '│', 'FloatBorder' },
}

local handlers = {
  ['textDocument/hover'] = vim.lsp.with(noice.hover, { border = border }),
  ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
}

local servers = {
  clangd = {},
  bashls = {},
  dockerls = {},
  docker_compose_language_service = {},
  gopls = {
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  },
  helm_ls = {
    settings = {
      ['helm-ls'] = {
        logLevel = 'Info',
        valuesFile = {
          mainValuesFile = 'values.yaml',
          lintOverlayValuesFile = 'values.lint.yaml',
          additionalValuesFilesGlobPattern = 'values*.yaml',
        },
        yamlls = {
          enabled = true,
          diagnosticsLimit = 50,
          showDiagnosticsDirectly = false,
          path = 'yaml-language-server',
          config = {
            schemas = {
              kubernetes = 'templates/**',
            },
            completion = true,
            hover = true,
          },
        },
      },
    },
  },
  hyprls = {},
  jqls = {},
  jsonls = {},
  lua_ls = {
    -- Command and arguments to start the server.
    cmd = { 'lua-language-server' },

    -- Filetypes to automatically attach to.
    filetypes = { 'lua' },

    handlers = handlers,

    -- Sets the "root directory" to the parent directory of the file in the
    -- current buffer that contains either a ".luarc.json" or a
    -- ".luarc.jsonc" file. Files that share a root directory will reuse
    -- the connection to the same LSP server.
    root_markers = { '.luarc.json', '.luarc.jsonc' },

    -- Specific settings to send to the server. The schema for this is
    -- defined by the server. For example the schema for lua-language-server
    -- can be found here https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        }
      }
    }
  },
  markdownlint = {},
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          pylint = { enabled = false },
          pyflakes = { enabled = false },
          pycodestyle = {
            enabled = false,
            -- ignore = { 'E501', 'E302', 'E305', 'E226', 'E114', 'E121', 'E111', 'E114', 'E303' },
          },
        },
      },
    },
  },
  -- pyright = {
  --   settings = {
  --     python = {
  --       analysis = { diagnosticMode = 'off', typeCheckingMode = 'off' },
  --     },
  --   },
  -- },
  terraformls = {},
  -- tsserver = {},
  vimls = {},
  yamlls = {},
  yq = {}
}

-- Define LSP configurations using vim.lsp.config()
for server, config in pairs(servers) do
  vim.lsp.config[server] = config
end

-- Enable all defined configurations
for server, _ in pairs(servers) do
  vim.lsp.enable(server)
end
