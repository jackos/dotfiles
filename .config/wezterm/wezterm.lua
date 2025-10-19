local wezterm = require("wezterm")
local act = wezterm.action

local colors = {
	bg = "#1a1b26",
	fg = "#c0caf5",
	black = "#414868",
	red = "#f7768e",
	green = "#9ece6a",
	yellow = "#e0af68",
	blue = "#2ac3de",
	magenta = "#bb9af7",
	active_bg = "#2c2d42",
	cyan = "#7dcfff",
	white = "#a9b1d6",
	cursor = "#a9b1d6",
}

local colors_f =
	{ colors.black, colors.red, colors.green, colors.yellow, colors.blue, colors.magenta, colors.cyan, colors.white }

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)
return {
	keys = {
		{ key = "H", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 25 }) },
		{ key = "J", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 15 }) },
		{ key = "K", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 15 }) },
		{ key = "L", mods = "CTRL|ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 25 }) },
		{ key = "PageDown", action = act.ScrollByPage(1) },
		{ key = "PageUp", action = act.ScrollByPage(-1) },
		-- { key = "w", mods = "CTRL", action = act.CloseCurrentTab({ confirm = true }) },
		-- { key = "h", mods = "CTRL", action = act.ActivateTabRelative(-1) },
		-- { key = "l", mods = "CTRL", action = act.ActivateTabRelative(1) },
		{ key = "Enter", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
		{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
		{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
		{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
		{ key = "o", mods = "SHIFT|CTRL", action = wezterm.action.QuickSelect },
		-- { key = "w", mods = "CTRL", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
		{
			key = "w",
			mods = "CTRL|SHIFT",
			action = wezterm.action.SpawnCommandInNewWindow({ args = { "code", "cool" } }),
		},
		{ key = "l", mods = "SHIFT|CTRL", action = "ShowDebugOverlay" },
		{ key = "w", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
		{ key = "Enter", mods = "ALT", action = "DisableDefaultAssignment" },
		{ key = "t", mods = "ALT", action = wezterm.action({ SplitVertical = {} }) },
		{ key = "-", mods = "ALT", action = wezterm.action({ SplitHorizontal = {} }) },
		{ key = "f", mods = "ALT", action = wezterm.action.TogglePaneZoomState },
		-- { key = "v", mods = "CMD", action = wezterm.action_callback(function(_, _)
		--   local success, stdout, stderr = wezterm.run_child_process({ "clipmenu" })
		--   wezterm.log_info(success, stdout, stderr)
		-- end
		-- ) },
		{
			key = "u",
			mods = "ALT",
			action = wezterm.action.QuickSelectArgs({
				label = "open url",
				patterns = { "https?://\\S+" },
				action = wezterm.action_callback(function(window, pane)
					local url = window:get_selection_text_for_pane(pane)
					wezterm.log_info("opening: " .. url)
					wezterm.open_with(url)
				end),
			}),
		},

		{
			key = "Enter",
			mods = "ALT",
			action = wezterm.action_callback(function(_, pane)
				local dir = pane:get_current_working_dir()
				wezterm.log_info("opening dir:" .. dir)
				dir = dir:gsub("%s", "")
				wezterm.log_info("opening dir:" .. dir)
				dir = dir:gsub("file://", "")
				wezterm.log_info("opening dir:" .. dir)
				local success, stdout, stderr = wezterm.run_child_process({
					"wezterm",
					"cli",
					"spawn",
					"--new-window",
					"--cwd",
					dir,
				})
				wezterm.log_info(success, stdout, stderr)
			end),
		},

		{
			key = "o",
			mods = "ALT",
			action = wezterm.action.QuickSelectArgs({
				label = "code url",
				patterns = { ".*mojo.*" },
				action = wezterm.action_callback(function(window, pane)
					local dir = pane:get_current_working_dir()
					local url = window:get_selection_text_for_pane(pane)
					local dir = dir:gsub("%s", "")
					local dir = dir:gsub("file://", "")
					local file = dir .. "/" .. url
					wezterm.log_info("opening: " .. file)
					local success, stdout, stderr = wezterm.run_child_process({ "code", "-g", file })
					wezterm.log_info(success, stdout, stderr)
				end),
			}),
		},
		-- Will use git_root script to get the root directory that rust is running from
		-- 	{
		-- 		key = "o",
		-- 		mods = "ALT",
		-- 		action = wezterm.action.QuickSelectArgs({
		-- 			label = "code url",
		-- 			patterns = { "[^\\[\\s]*\\.rs:\\d+:*\\d*" },
		-- 			action = wezterm.action_callback(function(window, pane)
		-- 				local dir = pane:get_current_working_dir()
		-- 				local url = window:get_selection_text_for_pane(pane)
		-- 				dir = dir:gsub("%s", "")
		-- 				dir = dir:gsub("file://", "")
		-- 				local file = dir .. "/" .. url
		-- 				wezterm.log_info("opening: " .. file)
		-- 				local success, stdout, stderr = wezterm.run_child_process({
		-- 					--"wezterm", "cli", "split-pane", "--right", "helix", file
		-- 					-- "wezterm", "cli", "spawn", "--new-window", "--cwd", dir, "helix", file
		-- 					"hx",
		-- 					file,
		-- 				})
		-- 				wezterm.log_info(success, stdout, stderr)
		-- 			end),
		-- 		}),
		-- 	},
	},
	font = wezterm.font("Hack Nerd Font"),
	font_size = 18,
	window_close_confirmation = "NeverPrompt",
	--window_background_opacity = 0,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	enable_wayland = false,
	use_fancy_tab_bar = true,
	colors = {
		foreground = colors.fg,
		background = colors.bg,
		ansi = colors_f,
		cursor_fg = colors.cursor,
		cursor_bg = colors.cursor,
		cursor_border = colors.cursor,
		brights = colors_f,
		tab_bar = {
			inactive_tab_edge = colors.bg,
			background = colors.bg,
			active_tab = {
				bg_color = colors.bg,
				fg_color = colors.bg,
			},
			inactive_tab = {
				bg_color = colors.bg,
				fg_color = colors.bg,
			},
			new_tab = {
				bg_color = colors.bg,
				fg_color = colors.bg,
			},
		},
	},
	show_tab_index_in_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	enable_tab_bar = false,
	exit_behavior = "Close",
}
