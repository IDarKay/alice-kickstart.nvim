return {
  'lervag/vimtex',
  lazy = false, -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- VimTeX configuration goes here, e.g.
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_compiler_method = 'latexmk' -- Use latexmk for compilation
    vim.g.vimtex_syntax_enabled = 1 -- Ensure syntax highlighting is enabled
    vim.g.vimtex_complete_enabled = 1
  end,
}
