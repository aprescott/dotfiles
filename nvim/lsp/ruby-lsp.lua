return {

  filetypes = { "ruby" },

  cmd = { "ruby-lsp" }, -- or { "bundle", "exec", "ruby-lsp" },

  root_markers = { "Gemfile", ".git" },

  -- copilot.vim hardcodes UTF-16; listing it first avoids mixed-encoding
  -- warnings and broken go-to-definition when both servers share a buffer.
  capabilities = {
    general = {
      -- positionEncodings = { "utf-16", "utf-8" },
      positionEncodings = { "utf-8" },
    },
  },

  init_options = {
    formatter = 'standard',
    linters = { 'standard' },
    addonSettings = {
      ["Ruby LSP Rails"] = {
        enablePendingMigrationsPrompt = false,
      },
    },
  },
}
