vim.cmd('source ~/.vimrc')

require("config.lazy")

vim.api.nvim_set_hl(0, "VirtColumnColor", { fg = "#323232" })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#22262e" })
vim.api.nvim_set_hl(0, "Cursor", { bg = "#b0a693" })
vim.api.nvim_set_hl(0, "Visual", { fg = "#0e0d0b", bg = "#eecb8b" })
vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25"
vim.api.nvim_set_hl(0, "BufferLineOffsetSeparator", { fg = "#323232" })
vim.api.nvim_set_hl(0, "NeoTreeTitleBar", { fg = "#ffffff" })

require("virt-column").setup({
  highlight = "VirtColumnColor",
})

-- Bind super-backspace to delete to the beginning of the first non-blank
-- character, unless there are only blank characters before the cursor, in
-- which case it deletes to the beginning of the line.
vim.keymap.set('i', '<D-BS>', function()
  local col = vim.fn.col('.')
  local line = vim.fn.getline('.')
  local first_non_blank = line:find('%S') or 0
  if col > first_non_blank then
    vim.cmd('normal! d^')
  else
    vim.cmd('normal! d0')
  end
end, { noremap = true, silent = true })

local function toggle_comment(normal_cmd, col_offset, is_visual)
  local col = vim.fn.col('.')
  local cursor_line = vim.fn.line('.')
  local line = vim.fn.getline(cursor_line)

  -- gcc skips empty lines, so insert the comment prefix manually.
  -- Skip this in visual mode: gc should operate on the whole selection.
  if not is_visual and line == '' then
    local prefix = vim.bo.commentstring:match('^(.-)%s*%%s') or ''
    vim.fn.setline(cursor_line, prefix .. ' ')
    vim.fn.cursor(cursor_line, #prefix + 1 + (col_offset or 0))
    return
  end

  local len_before = #line
  vim.cmd('normal ' .. normal_cmd)
  local delta = #vim.fn.getline(cursor_line) - len_before
  vim.fn.cursor(cursor_line, math.max(1, col + delta + (col_offset or 0)))
end

vim.keymap.set("n", "<D-/>", function()
  toggle_comment('gcc')
end, { noremap = true, silent = true })

vim.keymap.set("x", "<D-/>", function()
  toggle_comment('gc', nil, true)
end, { noremap = true, silent = true })

-- Toggle commenting in insert mode and preserve cursor position.
vim.keymap.set("i", "<D-/>", function()
  vim.cmd('stopinsert')
  toggle_comment('gcc', 1)
  -- startinsert must be deferred so it runs after the normal-mode
  -- operations have fully settled; calling it synchronously here
  -- has no effect and leaves the editor in normal mode.
  vim.schedule(function()
    vim.cmd('startinsert')
  end)
end, { noremap = true, silent = true })

vim.keymap.set({"n", "x"}, "{", "}")
vim.keymap.set({"n", "x"}, "}", "{")

vim.keymap.set("n", "<D-j>", "G")
vim.keymap.set("n", "<D-k>", "gg")
vim.keymap.set("n", "<D-down>", "G")
vim.keymap.set("n", "<D-up>", "gg")

vim.keymap.set("n", "p", "p=`[")

vim.keymap.set("n", "<C-S-,>", "<C-w>W")
vim.keymap.set("n", "<C-S-.>", "<C-w>w")

vim.keymap.set("n", "<C-,>", "<cmd>bprev<cr>")
vim.keymap.set("n", "<C-.>", "<cmd>bnext<cr>")

vim.keymap.set("n", "<D-S-\\>", "<cmd>vsplit<cr><C-w>l")

vim.keymap.set("n", "<D-e>", "<cmd>Neotree toggle<cr>")

vim.lsp.enable({ "ruby-lsp", "sorbet", "ts_ls" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local map = function(k, f) vim.keymap.set("n", k, f, { buffer = args.buf }) end
    map("gd",  vim.lsp.buf.definition)
    map("K",   vim.lsp.buf.hover)
    map("gr",  vim.lsp.buf.references)
    map("grn", vim.lsp.buf.rename)
  end,
})
