local function register_jai_parser()
  require("nvim-treesitter.parsers").jai = {
    tier = 0,
    install_info = {
      url = "https://github.com/constantitus/tree-sitter-jai.git",
      queries = "queries",
      revision = "2763e5001856ea7b5047e780e8dec95a07072d59",
    },
  }
end

vim.filetype.add({ extension = { jai = "jai" } })

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      register_jai_parser()

      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("jai_treesitter_parser", { clear = true }),
        pattern = "TSUpdate",
        callback = register_jai_parser,
      })

      opts.highlight = opts.highlight or {}
      opts.highlight.enable = true

      if opts.ensure_installed == nil then
        opts.ensure_installed = { "jai" }
      elseif type(opts.ensure_installed) == "table" and not vim.tbl_contains(opts.ensure_installed, "jai") then
        table.insert(opts.ensure_installed, "jai")
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jails = {
          mason = false,
          -- Use the path where you moved the jails LSP server
          cmd = { vim.fn.expand("~/.local/bin/jails") },
          filetypes = { "jai" },
          root_markers = { ".git" },
          single_file_support = true,
        },
      },
    },
  },
}
