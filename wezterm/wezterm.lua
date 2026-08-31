local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- >>> theme (managed by Set-Theme — do not edit between the markers) >>>
local scheme = 'Catppuccin Macchiato'
local pal = {
  bar      = '#24273a',
  inactive = '#363a4f',
  active   = '#c6a0f6',
  hover    = '#494d64',
  fg       = '#cad3f5',
  fg_dim   = '#6e738d',
  dark     = '#1e2030',
}
local font = "CaskaydiaMono NF"
local term = nil
-- <<< theme <<<

config.default_prog = { "pwsh.exe", "-NoLogo" }
config.color_scheme = scheme

-- Rendering: the default WebGpu front-end can leave stale/ghost cells behind
-- (un-repainted regions) on some GPUs/drivers. OpenGL is more reliable here.
-- If ghosting persists, try 'Software'. Revert by deleting this line.
config.front_end = "OpenGL"
-- Single patched Nerd Font: text + icons share one typeface (no fallback
-- mismatch). Segoe UI Emoji only handles color emoji, which no mono font has.
-- NOTE: WezTerm weights are "Regular"/"DemiBold"/"Bold" etc. — NOT "Normal".
config.font = wezterm.font_with_fallback({
	{ family = font or "ComicShannsMono Nerd Font", weight = "Regular" },
	{ family = "Leelawadee UI" }, -- Thai glyph fallback (ships with Windows)
	{ family = "Segoe UI Emoji" },
})
config.font_size = 8
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.default_cursor_style = "SteadyBlock"
config.foreground_text_hsb = {
	hue = 1.0,
	saturation = 1.0,
	brightness = 1.0,
}
config.pane_focus_follows_mouse = false
config.enable_wayland = false
config.automatically_reload_config = true
config.exit_behavior = "Close"

-- Quality of life
config.scrollback_lines = 10000
config.window_close_confirmation = "NeverPrompt"

-- Right-click / dropdown launch menu
config.launch_menu = {
	{ label = "PowerShell", args = { "pwsh.exe", "-NoLogo" } },
	-- attach-or-create the 'work' session (the -A flag = attach if exists, else create)
	{ label = "psmux: work", args = { "pwsh.exe", "-NoLogo", "-NoExit", "-Command", "tmux new-session -A -s work" } },
	{ label = "psmux: me", args = { "pwsh.exe", "-NoLogo", "-NoExit", "-Command", "tmux new-session -A -s me" } },
}

-- Keybindings
config.keys = {
	-- Ctrl+Shift+W: open a tab attached to the 'work' psmux session (creates it if missing)
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SpawnCommandInNewTab({
			args = { "pwsh.exe", "-NoLogo", "-NoExit", "-Command", "tmux new-session -A -s work" },
		}),
	},
	-- Font size
	{ key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },

	-- Tab management
	{ key = "t", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "q", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
	{ key = "Tab", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) }, -- next tab
	{ key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) }, -- previous tab
	-- Ctrl+Shift+Left/Right: switch to the tab on the left / right
	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
	-- PageUp/PageDown: switch tabs (no modifier)
	{ key = "PageUp", mods = "NONE", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "PageDown", mods = "NONE", action = wezterm.action.ActivateTabRelative(1) },

	-- NOTE: Ctrl+h / Ctrl+l are intentionally NOT bound to tab nav — they belong to
	-- Neovim window navigation (Ctrl+hjkl). Use Ctrl+Tab / Ctrl+Shift+Tab for tabs,
	-- and Ctrl+Shift+hjkl for WezTerm pane nav. This keeps Ctrl+l = clear-screen in a shell.

	-- Pane splits (vim convention): Ctrl+Alt+v = vertical divider (left|right),
	-- Ctrl+Alt+h = horizontal divider (top/bottom). Uses ALT so Ctrl+Shift+v stays paste.
	{ key = "v", mods = "CTRL|ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "CTRL|ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "x", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },

	-- Pane navigation: Ctrl+Shift+h/j/k/l move focus between splits.
	-- (ALT is left free so psmux's own Alt+h/j/k/l pane nav still works inside a session.)
	{ key = "h", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },

	-- Pane resize: Alt+Shift+h/j/k/l
	{ key = "h", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 3 }) },
	{ key = "j", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 3 }) },
	{ key = "k", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 3 }) },
	{ key = "l", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 3 }) },
}

-- Ctrl+Shift+1..9 jumps straight to tab N
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

-- ── Tab bar styling (theme-driven, fancy bar — taller + more spacing) ─────────
config.use_fancy_tab_bar = true -- fancy bar lets window_frame.font_size set height
config.tab_bar_at_bottom = false
config.tab_max_width = 20
config.show_new_tab_button_in_tab_bar = true

local drac = pal -- tab-bar palette comes from the managed theme block up top

-- The fancy tab bar's HEIGHT is driven by this font_size — raise it for taller tabs.
config.window_frame = {
	font = wezterm.font({ family = font or "ComicShannsMono Nerd Font", weight = "Regular" }),
	font_size = 9, -- ↑ increase for even taller tabs
	active_titlebar_bg = drac.bar,
	inactive_titlebar_bg = drac.bar,
}

config.colors = {
	tab_bar = {
		background = drac.bar,
		active_tab = { bg_color = drac.active, fg_color = drac.dark, intensity = "Bold" },
		inactive_tab = { bg_color = drac.inactive, fg_color = drac.fg_dim },
		inactive_tab_hover = { bg_color = drac.hover, fg_color = drac.fg },
		new_tab = { bg_color = drac.bar, fg_color = drac.hover },
		new_tab_hover = { bg_color = drac.hover, fg_color = drac.fg },
	},
}
-- term (set in the managed block above) carries exact ANSI/cursor/selection colors
-- for themes with no matching WezTerm-bundled scheme; merge them over color_scheme's.
if term then
	for k, v in pairs(term) do
		config.colors[k] = v
	end
end

wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
	local idx = tab.tab_index + 1
	local title = (tab.tab_title and #tab.tab_title > 0) and tab.tab_title or tab.active_pane.title
	title = title:gsub("%.exe$", "") -- drop .exe
	if tab.active_pane.is_zoomed then
		title = " " .. title
	end
	-- padding on both sides widens each tab → more breathing room between tabs
	local label = "   " .. idx .. "  " .. title .. "   "
	return { { Text = wezterm.truncate_right(label, max_width) } }
end)

return config
