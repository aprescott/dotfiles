vim.cmd('source ~/.vimrc')

require("config.lazy")

vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Removes trailing whitespace on save',
  callback = function()
    local save_cursor = vim.fn.getpos('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
  end,
})
