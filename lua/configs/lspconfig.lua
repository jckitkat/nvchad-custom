require("nvchad.configs.lspconfig").defaults()

local servers = {"clangd", "jedi-language-server", "lua-language-server", "rust-analyzer", "jdtls", "gopls", "qmlls"}
vim.lsp.enable(servers)

vim.lsp.config("rust-analyzer", {
  cmd = { 'rust-analyzer' },
  root_markers = {'.git', 'Cargo.toml'},
  filetypes = {'rust'},
})

vim.lsp.config("jedi-language-server", {
  cmd = { 'jedi-language-server' },
  root_markers = {'.git', 'requirements.txt', 'venv'},
  filetypes = {'python'},
})

-- read :h vim.lsp.config for changing options of lsp servers 
