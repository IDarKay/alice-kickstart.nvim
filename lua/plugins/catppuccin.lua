return {
  'catppuccin/nvim',
  priority = 1001,
  init = function()
    vim.cmd.colorscheme 'catppuccin'
  end,
}
