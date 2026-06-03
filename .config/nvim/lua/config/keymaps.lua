-- Defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local map = vim.keymap.set
local all_modes = { "n", "t", "v", "i" }
local sn = { silent = true, noremap = true }

local keybindings_all_modes = {
  { "<A-S-j>", ":split<CR>", "Split window below" },
}

local function listed_bufs()
  local bufs = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted then
      table.insert(bufs, b)
    end
  end
  return bufs
end

map(all_modes, "<C-l>", function()
  local bufs = listed_bufs()
  if vim.env.TMUX and (#bufs <= 1 or vim.api.nvim_get_current_buf() == bufs[#bufs]) then
    vim.system({ "tmux", "next-window" })
  else
    vim.cmd("bnext")
  end
end, { desc = "Next buffer / tmux window", unpack(sn) })

map(all_modes, "<C-h>", function()
  local bufs = listed_bufs()
  if vim.env.TMUX and (#bufs <= 1 or vim.api.nvim_get_current_buf() == bufs[1]) then
    vim.system({ "tmux", "previous-window" })
  else
    vim.cmd("bprevious")
  end
end, { desc = "Previous buffer / tmux window", unpack(sn) })

-- Copy file path
vim.keymap.set("n", "<leader>yp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy file path" })

-- Copy relative file path
vim.keymap.set("n", "<leader>yr", function()
  vim.fn.setreg("+", vim.fn.expand("%:p:."))
end, { desc = "Copy relative file path" })

map("n", "<A-w>", function()
  if #vim.api.nvim_list_wins() > 1 then
    vim.cmd("q")
  end
end, { desc = "Close window", unpack(sn) })
map("t", "<A-w>", "exit<CR>", { desc = "Close termanal" })
map("n", "<A-i>", vim.lsp.buf.hover, { desc = "Hover Documentation" })

vim.keymap.set("i", "<C-space>", function()
  vim.lsp.completion.get()
end)

for _, binding in ipairs(keybindings_all_modes) do
  map(all_modes, binding[1], binding[2], { desc = binding[3], unpack(sn) })
end

map("n", "<S-u>", "<C-r>", { desc = "Redo", unpack(sn) })

map("n", "<A-m>", function()
  local t0 = vim.uv.hrtime()
  local cursor = vim.fn.getcurpos()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input = table.concat(lines, "\n") .. "\n"
  local result = vim.system({ "mdlab" }, { stdin = input }):wait()
  local t1 = vim.uv.hrtime()
  if result.code ~= 0 then
    vim.notify(string.format("mdlab exit code %s:\n%s", result.code, result.stderr or ""), vim.log.levels.ERROR)
  else
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result.stdout, "\n", { plain = true }))
    vim.fn.setpos(".", cursor)
    local message = string.format("mdlab compiled and ran in: %.1fms", (t1 - t0) / 1e6)
    if result.stderr and result.stderr ~= "" then
      message = message .. "\n" .. result.stderr
    end
    vim.notify(message)
  end
end, { desc = "Process buffer with mdlab" })

-- snacks
map(all_modes, "<A-t>", function()
  Snacks.terminal()
end, { desc = "Toggle Terminal" })

Snacks.toggle.zoom():map("<A-f>")

map("t", "<A-esc>", "<C-\\><C-n>", { desc = "Exit terminal to normal mode" })
map("t", "<A-f>", "<C-\\><C-n>", { desc = "Overwrite zoom to exit terminal mode first" })

map("n", "<A-S-l>", ":vsplit<CR>", { desc = "Split window right" })

-- map("n", "<A-S-l>", function()
--   Snacks.terminal.open()
-- end, { desc = "New Terminal right" })

map(all_modes, "<C-w>", function()
  local bufs = listed_bufs()
  if #bufs <= 1 then
    vim.cmd("qa")
  else
    Snacks.bufdelete()
  end
end, { desc = "Delete Buffer / Quit", nowait = true })

map("n", "<leader>gf", function()
  Snacks.picker("git_log_file_diff")
end, { desc = "Diff file history" })

map("n", "gs", function()
  Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter })
end, { desc = "LSP Symbols" })

map("n", "gS", function()
  Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter })
end, { desc = "LSP Workspace Symbols" })

-- which-key
local wk = require("which-key")

wk.add({
  { "<leader>c", group = "Modify Config Files" }, -- Group for config files
  { "<leader>cm", ":edit ~/.config/nvim/lua/config/keymaps.lua<CR>", desc = "Neovim Keymaps" },
  { "<leader>cf", ":edit ~/.config/fish/config.fish<CR>", desc = "Fish" },
  { "<leader>ca", ":edit ~/.config/alacritty/alacritty.toml<CR>", desc = "Alacritty" },
  { "<leader>cl", ":edit ~/.config/lazygit/config.yml<CR>", desc = "Lazygit" },
  { "<leader>cg", ":edit ~/.config/ghostty/config<CR>", desc = "Ghostty" },
  {
    "<leader>cn",
    function()
      require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
    end,
    desc = "Neovim",
  },
}, { mode = "n" })

local mc = require("multicursor-nvim")

-- Add or skip cursor above/below the main cursor.
map({ "n", "x" }, "<up>", function()
  mc.lineAddCursor(-1)
end, { desc = "Add cursor above" })

map({ "n", "x" }, "<down>", function()
  mc.lineAddCursor(1)
end, { desc = "Add cursor below" })

map({ "n", "x" }, "<leader><C-k>", function()
  mc.lineSkipCursor(-1)
end)

map({ "n", "x" }, "<leader><C-j>", function()
  mc.lineSkipCursor(1)
end)

-- Add or skip adding a new cursor by matching word/selection
map({ "n", "x" }, "<A-n>", function()
  mc.matchAddCursor(1)
end, { desc = "Add cursor matching word next" })

map({ "n", "x" }, "<A-b>", function()
  mc.matchAddCursor(-1)
end, { desc = "Add cursor matching word back" })

map({ "n", "x" }, "<leader>C-m", function()
  mc.matchSkipCursor(1)
end)

map({ "n", "x" }, "<leader>C-n", function()
  mc.matchSkipCursor(-1)
end)

-- Mappings defined in a keymap layer only apply when there are
-- multiple cursors. This lets you have overlapping mappings.
mc.addKeymapLayer(function(layerSet)
  -- Select a different cursor as the main one.
  layerSet({ "n", "x" }, "<left>", mc.prevCursor)
  layerSet({ "n", "x" }, "<right>", mc.nextCursor)

  -- Delete the main cursor.
  layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)
  -- Enable and clear cursors using escape.
  layerSet("n", "<esc>", function()
    if not mc.cursorsEnabled() then
      -- mc.enableCursors()
    else
      mc.clearCursors()
    end
  end)
end)
