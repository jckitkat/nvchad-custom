require("nvchad.configs.lspconfig").defaults()

local servers = {"clangd", "jedi-language-server", "lua-language-server", "rust-analyzer", "jdtls", "gopls"}
vim.lsp.enable(servers)

vim.lsp.config("rust-analyzer", {
  cmd = { 'rust-analyzer' },
  root_markers = {'.git', 'Cargo.toml'},
  filetypes = {'rust'},
})

-- read :h vim.lsp.config for changing options of lsp servers 
