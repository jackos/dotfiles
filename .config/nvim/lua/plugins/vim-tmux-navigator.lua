return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
  },
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  keys = {
    { "<M-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left", mode = { "n", "t", "v", "i" } },
    { "<M-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down", mode = { "n", "t", "v", "i" } },
    { "<M-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up", mode = { "n", "t", "v", "i" } },
    { "<M-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right", mode = { "n", "t", "v", "i" } },
  },
}
