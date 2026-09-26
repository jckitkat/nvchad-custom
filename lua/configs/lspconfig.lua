require("nvchad.configs.lspconfig").defaults()

local servers = {"clangd", "jedi-language-server", "lua-language-server", "rust-analyzer", "jdtls", "gopls", "qmlls", "harper-ls"}
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

vim.lsp.config("clangd", {
  cmd = {
    'clangd',
    '--query-driver=/home/jc/opt/cross/bin/i686-elf-*,/usr/bin/aarch64-linux-gnu-*',
  },
})

-- read :h vim.lsp.config for changing options of lsp servers
