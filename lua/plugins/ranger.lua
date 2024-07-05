return {
  'kelly-lin/ranger.nvim',
  config = function()
    local ranger_nvim = require 'ranger-nvim'
    require('ranger-nvim').setup {
      enable_cmds = false,
      replace_netrw = false,
      keybinds = {
        ['sv'] = ranger_nvim.OPEN_MODE.vsplit,
        ['sh'] = ranger_nvim.OPEN_MODE.split,
        ['st'] = ranger_nvim.OPEN_MODE.tabedit,
        ['sr'] = ranger_nvim.OPEN_MODE.rifle,
      },
      ui = {
        border = 'none',
        height = 0.5,
        width = 0.6,
        x = 0.5,
        y = 0.5,
      },
    }
    vim.keymap.set('n', '<leader>rr', function()
      require('ranger-nvim').open(true)
    end, { desc = 'Open [R][R]anger' })
  end,
}
