-- Start screen shown when nvim opens with no file (snacks.dashboard; snacks is
-- already loaded for scroll/indent/notifier, so this replaced alpha-nvim).
return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      enabled = true,
      preset = {
        header = table.concat({
          "███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
          "████╗  ██║ ██╔════╝ ██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
          "██╔██╗ ██║ █████╗   ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
          "██║╚██╗██║ ██╔══╝   ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
          "██║ ╚████║ ███████╗ ╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
          "╚═╝  ╚═══╝ ╚══════╝  ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
        }, "\n"),
        -- Same actions as your space-f keymaps; press the single key on the dashboard.
        keys = {
          { icon = "\u{f002} ", key = "f", desc = "Find file", action = "<cmd>Telescope find_files<cr>" },
          { icon = "\u{f0b0} ", key = "g", desc = "Grep text", action = "<cmd>Telescope live_grep<cr>" },
          { icon = "\u{f1da} ", key = "r", desc = "Recent files", action = "<cmd>Telescope oldfiles<cr>" },
          { icon = "\u{f15b} ", key = "n", desc = "New file", action = "<cmd>enew<cr>" },
          { icon = "\u{f07b} ", key = "e", desc = "File explorer", action = "<cmd>Neotree toggle filesystem left<cr>" },
          { icon = "\u{f0e7} ", key = "l", desc = "Lazy", action = "<cmd>Lazy<cr>" },
          { icon = "\u{f011} ", key = "q", desc = "Quit", action = "<cmd>qa<cr>" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { icon = "\u{f1da} ", title = "Recent Files", section = "recent_files", cwd = true, indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
  },
}
