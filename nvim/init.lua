vim.cmd('source ~/.vimrc')

vim.pack.add({
  "lukas-reineke/virt-column.nvim"
})

require("virt-column").setup()

