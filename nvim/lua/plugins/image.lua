-- snacks.nvim modules:
-- image: inline image preview (png/jpg/gif/pdf/svg) via WezTerm's Kitty graphics
--   protocol. Requires ImageMagick's `magick` CLI on PATH for conversion.
-- scroll: disabled (no smooth scrolling).
-- notifier/input: pretty vim.notify popups and rename/input box.
-- indent: indent guides with animated current scope (replaces indent-blankline).
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		image = { enabled = true },
		notifier = { enabled = true, style = "compact" },
		input = { enabled = true },
		indent = {
			enabled = true,
			indent = { char = "│" },
			scope = { char = "│" },
			animate = { duration = { step = 15, total = 300 }, easing = "inOutQuad" },
		},
		scroll = { enabled = false },
	},
}
