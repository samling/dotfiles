return {
    'kylechui/nvim-surround',
    version = '*',
    event = 'VeryLazy',
    dependencies = { 'folke/which-key.nvim' },
    config = function()
        require('nvim-surround').setup()
        require('which-key').add({
            { 'ys', desc = 'Add surround', mode = 'n' },
            { 'yss', desc = 'Add surround (line)', mode = 'n' },
            { 'yS', desc = 'Add surround (new lines)', mode = 'n' },
            { 'ySS', desc = 'Add surround (line, new lines)', mode = 'n' },
            { 'ds', desc = 'Delete surround', mode = 'n' },
            { 'cs', desc = 'Change surround', mode = 'n' },
            { 'cS', desc = 'Change surround (new lines)', mode = 'n' },
            { 'S', desc = 'Add surround (visual)', mode = 'x' },
            { 'gS', desc = 'Add surround (visual, new lines)', mode = 'x' },
            { '<C-g>s', desc = 'Add surround (insert)', mode = 'i' },
            { '<C-g>S', desc = 'Add surround (insert, new lines)', mode = 'i' },
        })
    end,
}
