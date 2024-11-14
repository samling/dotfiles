return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile', 'BufEnter' },
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local lsp = require("lspconfig");
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    lsp.lua_ls.setup({
      capabilities = capabilities,
      settings = {
        Lua = {
          workspace = { checkThirdParty = false },
          completion = { callSnippet = "Replace" },
        }
      }
    })

    local servers = {
      -- clangd = {},
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
      jqls = {},
      jsonls = {},
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = {
                '${3rd}/luv/library',
                unpack(vim.api.nvim_get_runtime_file('', true)),
              },
            },
            diagnostics = { disable = { 'missing-fields' } },
          },
        },
      },
      markdownlint = {},
      -- pylint = {},
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
      yq = {},
    }

    -- lsp.basedpyright.setup {}

    require('mason').setup()

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua', -- Used to format lua code
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          lsp[server_name].setup {
            cmd = server.cmd,
            settings = server.settings,
            filetypes = server.filetypes,
            capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {}),
          }
        end,
      },
    }
  end,
}
