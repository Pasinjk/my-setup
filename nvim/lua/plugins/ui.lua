-- Active theme key, written by `Set-Theme` (see lua/config/theme.lua).
local current = require("config.theme")

-- Explicit integration list for the installed plugin set. Without this,
-- catppuccin's auto_integrations scans every installed plugin at setup time
-- to guess which integrations to turn on -- ~30ms wasted on every startup.
local catppuccin_integrations = {
	nvim_surround = true,
	gitsigns = true,
	indent_blankline = { enabled = true },
	mason = true,
	neotree = true,
	telescope = true,
	which_key = true,
	alpha = true,
	cmp = true,
	render_markdown = true,
	aerial = true,
}

-- Theme registry: every entry is installed so switching is instant (just change
-- config/theme.lua and restart), but only `current` is loaded + activated.
local themes = {
	["tokyonight-storm"] = {
		"folke/tokyonight.nvim",
		name = "tokyonight",
		scheme = "tokyonight-storm",
		lualine = "tokyonight",
		setup = function()
			require("tokyonight").setup({ style = "storm" })
		end,
	},
	["catppuccin-latte"] = {
		"catppuccin/nvim",
		name = "catppuccin",
		scheme = "catppuccin-latte",
		lualine = "catppuccin-latte",
		setup = function()
			require("catppuccin").setup({
				flavour = "latte",
				auto_integrations = false,
				integrations = catppuccin_integrations,
			})
		end,
	},
	["catppuccin-macchiato"] = {
		"catppuccin/nvim",
		name = "catppuccin",
		scheme = "catppuccin-macchiato",
		lualine = "catppuccin-macchiato",
		setup = function()
			require("catppuccin").setup({
				flavour = "macchiato",
				auto_integrations = false,
				integrations = catppuccin_integrations,
			})
		end,
	},
	["onelight"] = {
		"navarasu/onedark.nvim",
		name = "onedark",
		scheme = "onedark",
		lualine = "onelight",
		setup = function()
			require("onedark").setup({ style = "light" })
		end,
	},
	["tokyonight-day"] = {
		"folke/tokyonight.nvim",
		name = "tokyonight",
		scheme = "tokyonight-day",
		lualine = "tokyonight",
		setup = function()
			require("tokyonight").setup({ style = "day" })
		end,
	},
	["aura"] = {
		"daltonmenezes/aura-theme",
		name = "aura",
		scheme = "aura-soft-dark",
		-- No dedicated lualine theme ships with it; `auto` derives one from the colors.
		lualine = "auto",
		-- The colorscheme lives in a subdir of the repo, not at its root, so the
		-- plugin dir alone isn't on the runtimepath -- append the subdir by hand.
		setup = function()
			vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/aura/packages/neovim")
		end,
	},
	["rose-pine-moon"] = {
		"rose-pine/neovim",
		name = "rose-pine-moon",
		scheme = "rose-pine",
		lualine = "auto",
		setup = function()
			require("rose-pine").setup({ variant = "moon" })
		end,
	},
}

-- The active theme entry (also supplies lualine's theme name, used below).
local active_theme = themes[current] or themes["onelight"]
local lualine_theme = active_theme.lualine

-- Build plugin specs, active theme first, deduped by repo: entries can share a
-- repo (tokyonight storm/day) and lazy.nvim keys plugins by repo, so two specs
-- for one repo collide -- `pairs()` order decided which one survived, which
-- randomly dropped the active theme (and its colorscheme) at startup.
local theme_specs, seen = {}, {}
local function add_theme(t, active)
	if seen[t[1]] then
		return
	end
	seen[t[1]] = true
	theme_specs[#theme_specs + 1] = {
		t[1],
		name = t.name,
		lazy = not active, -- inactive themes are installed but not loaded
		priority = active and 1000 or nil,
		config = active and function()
			t.setup()
			vim.cmd.colorscheme(t.scheme)
		end or nil,
	}
end

add_theme(active_theme, true)
for _, t in pairs(themes) do
	add_theme(t, false)
end

-- Other UI specs, merged into theme_specs below via vim.list_extend rather than
-- returned as `{ unpack(theme_specs), other_specs... }` -- unpack() only expands
-- to multiple values as the LAST element of a table constructor; anywhere else
-- Lua truncates it to one, which previously dropped all but one colorscheme spec.
local other_specs = {
	-- Buffers rendered as tabs, driven by <S-h>/<S-l>
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {
			options = {
				diagnostics = "nvim_lsp",
				always_show_bufferline = true,
				offsets = {
					{ filetype = "neo-tree", text = "Explorer", separator = true },
				},
			},
		},
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {
			options = {
				theme = lualine_theme,
				globalstatus = true,
				component_separators = { left = "›", right = "‹" },
			},
			sections = {
				lualine_b = {
					{ "branch", icon = "🌳" },
					-- Emoji instead of Nerd Font glyphs -- no special font needed.
					{
						"diagnostics",
						symbols = { error = "❌ ", warn = "⚠️ ", info = "ℹ️ ", hint = "💡 " },
					},
				},
				lualine_c = {
					-- cwd's basename, LazyVim-style project-root breadcrumb.
					{ function() return vim.fn.fnamemodify(vim.loop.cwd(), ":t") end, icon = "🗂️" },
					-- LazyVim-style pretty path: relative to cwd, middle-truncated, with a
					-- modified/readonly marker -- plain vim.fn/vim.bo, no extra plugin.
					{
						function()
							local path = vim.fn.expand("%:~:.")
							if path == "" then
								return "[No Name]"
							end
							local parts = vim.split(path, "[\\/]")
							if #parts > 3 then
								parts = { parts[1], "…", unpack(parts, #parts - 1, #parts) }
							end
							local out = table.concat(parts, "/")
							if vim.bo.modified then
								out = out .. " ●"
							end
							if vim.bo.readonly then
								out = out .. " 🔒"
							end
							return out
						end,
						icon = "📄",
					},
				},
				-- Attached LSP client names (useful with vtsls+vue_ls+eslint+tailwindcss
				-- all potentially live on one buffer) ahead of the default encoding info.
				lualine_x = {
					{
						function()
							local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))
							return table.concat(names, " ")
						end,
						icon = "🔌",
					},
					-- Pending lazy.nvim plugin updates (same source LazyVim's own statusline uses).
					{
						require("lazy.status").updates,
						cond = require("lazy.status").has_updates,
						icon = "🔄",
					},
					"diff",
					{ "encoding", icon = "🔤" },
					{ "fileformat", icons_enabled = false },
					{ "filetype", icons_enabled = false },
				},
				lualine_y = {
					-- Live "[2/7]" match count while a search is active; empty otherwise.
					{ "searchcount", icon = "🔍" },
					"progress",
				},
				lualine_z = {
					-- Only shown while recording a macro (q + register).
					{
						function() return "⏺ REC @" .. vim.fn.reg_recording() end,
						cond = function() return vim.fn.reg_recording() ~= "" end,
					},
					{ "location", icon = "📍" },
					{ function() return os.date("%H:%M") end, icon = "🕐" },
				},
			},
			-- Clean single-section statuslines for panel/dashboard buffers instead of
			-- lualine trying to render filename/diagnostics/etc. for them.
			extensions = { "neo-tree", "lazy", "toggleterm", "aerial" },
		},
	},

	-- Leader-key hints (shows your space-menu as you type)
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			spec = {
				{ "<leader>b", group = "buffer" },
				{ "<leader>c", group = "code" },
				{ "<leader>d", group = "diagnostics" },
				{ "<leader>f", group = "find/file" },
				{ "<leader>m", group = "markdown" },
				{ "<leader>r", group = "rename" },
				{ "<leader>s", group = "split" },
			},
		},
	},

	-- Indent guides (Zed: indent_guides enabled)
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
		main = "ibl",
		opts = { indent = { char = "│" }, scope = { enabled = true } },
	},

	-- Inline color swatches (#hex / rgb() / hsl() + Tailwind classes) are configured
	-- in plugins/colorizer.lua -- a single dedicated spec, so it isn't declared here.
}

return vim.list_extend(theme_specs, other_specs)
