return {
  'chrisbra/Colorizer',
  config = function()
    vim.keymap.set('n', '<Leader>to', ':ColorToggle<Enter>', { desc = '[T]oggle c[O]lor' })
  end,
}
