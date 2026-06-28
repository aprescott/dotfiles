return {
  filetypes = { "ruby" },
  cmd = { "bundle", "exec", "srb", "typecheck", "--lsp" },
  root_markers = { "sorbet/config" },
}
