require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = 'both' -- to enable cursorline!

o.relativenumber = true

vim.g.pioConfig = {
  lsp = 'clangd',          -- value: clangd | ccls
  clangd_source = 'ccls',  -- value: ccls | compiledb, For detailed explation check :help platformio-clangd_source
  menu_key = '<leader>\\', -- replace this menu key  to your convenience
  debug = false,           -- enable debug messages
}
local pok, platformio = pcall(require, 'platformio')
if pok then
  platformio.setup(vim.g.pioConfig)
end

-- 1. Create a group to prevent duplicates
-- local rust_lsp_starter = vim.api.nvim_create_augroup('MyCustomGroup', { clear = true })
--
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "rust" },
--   command = "LspStart rust-analyzer",   -- Use 'command' for Vim commands
--   group = rust_lsp_starter,
-- })
