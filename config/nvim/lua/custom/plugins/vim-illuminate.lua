-- vim-illuminate highlights other uses of the word under the cursor.
--
return {
  'RRethy/vim-illuminate',
  opts = {
    delay = 200,
    large_file_cutoff = 2000,
    large_file_overrides = {
      proviers = { 'lsp' },
    },
  },
  config = function(_, opts)
    require('illuminate').configure(opts)
  end,
}
