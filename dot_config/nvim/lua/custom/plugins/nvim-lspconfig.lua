return {
  "neovim/nvim-lspconfig",
  opts = {
    -- Folke has a keymap to toggle inaly hints with <leader>uh
    inlay_hints = { enabled = false },

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
      lua_ls = {}, -- handled by lazydev
      pylsp = {
        settings = {
          pylsp = {
            plugins = {
              pylint = { enabled = false },
              pyflakes = { enabled = false },
              pycodestyle = {
                enabled = false,
              },
            },
          },
        },
      },
      terraformls = {},
      vimls = {},
      yamlls = {},
    }
  },
  config = function(_, opts)
    local lspconfig = require("lspconfig")
    
    for server, config in pairs(opts.servers) do
      lspconfig[server].setup(config)
    end
  end
}
