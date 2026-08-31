-- Start screen shown when nvim opens with no file (replaces the blank [No Name] buffer).
return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "                                                     ",
      "  ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
      "  ████╗  ██║ ██╔════╝ ██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
      "  ██╔██╗ ██║ █████╗   ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
      "  ██║╚██╗██║ ██╔══╝   ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
      "  ██║ ╚████║ ███████╗ ╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
      "  ╚═╝  ╚═══╝ ╚══════╝  ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
      "                                                     ",
    }

    -- Buttons use the SAME keys as your normal keymaps, so they're muscle-memory.
    dashboard.section.buttons.val = {
      dashboard.button("space f f", "  Find file", "<cmd>Telescope find_files<cr>"),
      dashboard.button("space f g", "  Grep text", "<cmd>Telescope live_grep<cr>"),
      dashboard.button("space f p", "  Recent files", "<cmd>Telescope oldfiles<cr>"),
      dashboard.button("space f n", "  New file", "<cmd>enew<cr>"),
      dashboard.button("space e", "  File explorer", "<cmd>Neotree toggle filesystem left<cr>"),
      dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
    }

    dashboard.section.footer.val = "  Neovim · mapped from your Zed keybinds"
    dashboard.opts.layout[1].val = 2 -- top padding

    alpha.setup(dashboard.opts)
  end,
}
