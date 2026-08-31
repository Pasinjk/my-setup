# dotfiles

nvim + wezterm config, both for Windows.

## Setup on a new machine

Needs [PowerShell 7+](https://github.com/PowerShell/PowerShell) (`pwsh`) — it's
cross-platform, so the same script runs on Windows, Linux, and macOS.

```powershell
git clone git@github.com:Pasinjk/my-setup.git ~/dotfiles
cd ~/dotfiles
pwsh ./setup.ps1
```

`setup.ps1` symlinks:

- Windows: `nvim/` -> `%LOCALAPPDATA%\nvim`, `wezterm/wezterm.lua` -> `%USERPROFILE%\.wezterm.lua`
- Linux/macOS: `nvim/` -> `$XDG_CONFIG_HOME/nvim` (or `~/.config/nvim`), `wezterm/wezterm.lua` -> `~/.wezterm.lua`

Anything already at those paths is backed up (renamed with a `.bak-<timestamp>`
suffix) before the symlink is created.

Windows only: creating a symlink needs Developer Mode on (Settings > Update &
Security > For developers) or an elevated shell — otherwise `New-Item
-ItemType SymbolicLink` fails with "you do not have sufficient privilege".
Linux/macOS need no special privilege for a symlink under `$HOME`.

Then install a Nerd Font (wezterm.lua expects `CaskaydiaMono NF`) and open
nvim once to let lazy.nvim install plugins from `lazy-lock.json`.
