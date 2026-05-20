-- This will run last in the setup process.

-- Track last-used toggleterm ID for terminal cycling
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*toggleterm#*",
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local id = tonumber(bufname:match("#(%d+)$"))
    if id then vim.g._last_toggleterm = id end
  end,
})
