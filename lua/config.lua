-- Set indentation to 4 spaces
vim.opt.tabstop = 4        -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4     -- Number of spaces used for each indentation level
vim.opt.expandtab = true   -- Use spaces instead of tabs
-- In init.lua or lua/config.lua
vim.opt.number = true
-- vim.opt.relativenumber = true
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = "silent! lua vim.lsp.buf.format()"
})

