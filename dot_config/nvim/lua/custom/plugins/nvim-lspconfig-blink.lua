-- nvim-lspconfig is a "data only" repo, providing basic, default Nvim LSP client configurations for various LSP servers.
--
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'saghen/blink.cmp',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    -- "hrsh7th/cmp-nvim-lsp",
  },
  opts = {
    servers = {
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
      lua_ls = {},
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
      yq = {},
    },
  },
  config = function(_, opts)
    local lspconfig = require("lspconfig");

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
    local noice = require("noice")

    local handlers = {
      ['textDocument/hover'] = vim.lsp.with(noice.hover, { border = border }),
      ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
    }

    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      handlers = handlers,
      settings = {
        Lua = {
          workspace = { checkThirdParty = false },
          completion = { callSnippet = "Replace" },
        }
      }
    })

    vim.diagnostic.config({
        virtual_text = {
            prefix = '■ ', -- Could be '●', '▎', 'x', '■', , 
        },
        -- float = { border = border },
    })

    for server, config in pairs(opts.servers) do
      capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
      lspconfig[server].setup(config)
    end

    require('mason').setup()

    local ensure_installed = vim.tbl_keys(opts.servers or {})
    vim.list_extend(ensure_installed, {
      'stylua', -- Used to format lua code
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = opts.servers[server_name] or {}
          lspconfig[server_name].setup {
            cmd = server.cmd,
            handlers = handlers,
            settings = server.settings,
            filetypes = server.filetypes,
            capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {}),
          }
        end,
      },
    }
  end,
 }
