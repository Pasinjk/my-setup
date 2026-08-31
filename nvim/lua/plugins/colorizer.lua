-- Renders colors inline: hex/rgb/hsl values AND Tailwind classes
-- (text-red-500, bg-blue-600, border-emerald-400, …).
-- `tailwind = "both"` uses a static class map + the tailwindcss LSP for accuracy.
return {
  "catgoose/nvim-colorizer.lua",
  event = "BufReadPre",
  opts = {
    filetypes = { "*" },
    user_default_options = {
      names = false,        -- don't colorize plain words like "red" / "green"
      tailwind = "both",    -- Tailwind class colors (static map + LSP)
      css = true,           -- enable all CSS features (rgb_fn, hsl_fn, etc.)
      css_fn = true,
      RGB = true,
      RRGGBB = true,
      RRGGBBAA = true,
      rgb_fn = true,
      hsl_fn = true,
      mode = "background",  -- paint the class/value with its color
    },
  },
}
