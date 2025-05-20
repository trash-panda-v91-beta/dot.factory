local w = require("wezterm")

w.on("format-tab-title", function(tab)
	local tab_index = string.format("  %s  ", tab.tab_index + 1)
	return w.format({
		{ Text = tab_index },
	})
end)

local function is_vim(pane)
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = w.action_callback(function(win, pane)
			if is_vim(pane) then
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

local is_linux = function()
	return w.target_triple:find("linux") ~= nil
end

local is_darwin = function()
	return w.target_triple:find("darwin") ~= nil
end

local config = {
	cursor_blink_rate = 0,
	hide_tab_bar_if_only_one_tab = true,
	-- default_prog = { "${pkgs.fish}/bin/fish", "--login" },
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = {
		{
			key = "-",
			mods = "CTRL",
			action = w.action.DisableDefaultAssignment,
		},
		{
			key = "=",
			mods = "CTRL",
			action = w.action.DisableDefaultAssignment,
		},
		{
			mods = "LEADER",
			key = "-",
			action = w.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			mods = "LEADER",
			key = "=",
			action = w.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			mods = "LEADER",
			key = "m",
			action = w.action.TogglePaneZoomState,
		},
		-- rotate panes
		{
			mods = "LEADER",
			key = "Space",
			action = w.action.RotatePanes("Clockwise"),
		},
		-- show the pane selection mode, but have it swap the active and selected panes
		{
			mods = "LEADER",
			key = "0",
			action = w.action.PaneSelect({
				mode = "SwapWithActive",
			}),
		},
		-- move between split panes
		split_nav("move", "h"),
		split_nav("move", "j"),
		split_nav("move", "k"),
		split_nav("move", "l"),
		-- resize panes
		split_nav("resize", "h"),
		split_nav("resize", "j"),
		split_nav("resize", "k"),
		split_nav("resize", "l"),
	},
	hide_mouse_cursor_when_typing = true,
	default_cursor_style = "SteadyBar",
	inactive_pane_hsb = {
		saturation = 0.7,
		brightness = 0.6,
	},
	front_end = "WebGpu",
	window_padding = {
		left = "1.5cell",
		right = "1cell",
		top = "2cell",
		bottom = "0.5cell",
	},
	use_fancy_tab_bar = false,
	tab_max_width = 30,
	show_new_tab_button_in_tab_bar = false,
	tab_bar_at_bottom = true,
}

if is_darwin then
	config.native_macos_fullscreen_mode = true
	config.window_background_opacity = 0.9
	config.macos_window_background_blur = 20
	config.window_decorations = "INTEGRATED_BUTTONS"
	config.font_size = 13.5
end

if is_linux then
	config.enable_wayland = false
end

return config
