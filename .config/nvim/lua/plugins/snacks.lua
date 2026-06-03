-- Get rid of ugly lines in diff
vim.opt.fillchars:append({ diff = " " })
return {
	"folke/snacks.nvim",
	opts = function(_, opts)
		opts.picker = opts.picker or {}
		opts.picker.sources = opts.picker.sources or {}
		opts.picker.sources.git_log_file_diff = {
			finder = "git_log",
			format = "git_log",
			preview = "git_show",
			current_file = true,
			follow = true,
			sort = { fields = { "score:desc", "idx" } },
			confirm = function(picker, item)
				local current_win = picker.main
				local current_buf = current_win
						and vim.api.nvim_win_is_valid(current_win)
						and vim.api.nvim_win_get_buf(current_win)
					or nil
				picker:close()
				if item and item.commit and item.file then
					-- Get git root directory
					local git_root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]
					if vim.v.shell_error ~= 0 then
						vim.notify("Not in a git repository", vim.log.levels.ERROR)
						return
					end

					local full_path = vim.fn.fnamemodify(item.file, ":p")

					-- Get relative path from git root
					local rel_path = vim.fn.systemlist({
						"git",
						"-C",
						git_root, -- Set git directory context
						"ls-files",
						"--full-name",
						full_path,
					})[1]
					if not rel_path or rel_path == "" then
						vim.notify("Could not resolve file path in git", vim.log.levels.ERROR)
						return
					end

					local git_follow = vim.fn.systemlist({
						"git",
						"-C",
						git_root, -- Set git directory context
						"log",
						"--follow",
						"--name-only",
						"--pretty=format:",
						item.commit .. "..",
						"--",
						rel_path,
					})

					-- Filter out empty lines and get the last one
					local result = {}
					for _, line in ipairs(git_follow) do
						if line ~= "" then
							table.insert(result, line)
						end
					end

					-- Get the last non-empty line
					local followed_path = result[#result] or rel_path
					if followed_path == "" then
						followed_path = rel_path
					end

					local git_output = vim.fn.system({
						"git",
						"-C",
						git_root, -- Set git directory context
						"show",
						("%s:%s"):format(item.commit, followed_path),
					})

					if vim.v.shell_error ~= 0 then
						vim.notify(git_output, vim.log.levels.ERROR)
						return
					end

					if not current_buf or not vim.api.nvim_buf_is_valid(current_buf) then
						vim.notify("Could not find the original file buffer", vim.log.levels.ERROR)
						return
					end
					if not current_win or not vim.api.nvim_win_is_valid(current_win) then
						vim.notify("Could not find the original file window", vim.log.levels.ERROR)
						return
					end

					local filetype = vim.bo[current_buf].filetype

					-- Create new scratch buffer
					vim.api.nvim_set_current_win(current_win)
					vim.cmd("leftabove vnew") -- or `new` for horizontal
					local history_win = vim.api.nvim_get_current_win()
					local new_buf = vim.api.nvim_create_buf(false, true) -- listed = false, scratch = true
					vim.api.nvim_win_set_buf(0, new_buf)

					-- Set string lines into scratch buffer
					local lines = vim.split(git_output, "\n", { plain = true })
					vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, lines)

					-- Align file type
					vim.bo[new_buf].filetype = filetype

					-- Enable diff mode on both buffers
					vim.api.nvim_win_call(current_win, function()
						vim.cmd("diffthis")
					end)
					vim.api.nvim_win_call(history_win, function()
						vim.cmd("diffthis")
					end)
				end
			end,
		}
		return opts
	end,
}
