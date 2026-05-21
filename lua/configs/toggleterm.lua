require("toggleterm").setup {
  size = 40,
  open_mapping = '<C-t>',
  start_in_insert = true,
  direction = 'float'
}

vim.cmd [[let &shell = '/usr/bin/env zsh']]

vim.cmd [[let &shellcmdflag = '-s']]
