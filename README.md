# dotfiles

nvim + wezterm config, both for Windows.

## Setup on a new machine

```powershell
git clone <this-repo-url> $env:USERPROFILE\dotfiles
cd $env:USERPROFILE\dotfiles
.\setup.ps1
```

`setup.ps1` symlinks:

- `nvim/` -> `%LOCALAPPDATA%\nvim`
- `wezterm/wezterm.lua` -> `%USERPROFILE%\.wezterm.lua`

Anything already at those paths is backed up (renamed with a `.bak-<timestamp>`
suffix) before the symlink is created.

Creating a symlink needs Developer Mode on (Settings > Update & Security > For
developers) or an elevated shell — otherwise `New-Item -ItemType
SymbolicLink` fails with "you do not have sufficient privilege".

Then install a Nerd Font (wezterm.lua expects `CaskaydiaMono NF`) and open
nvim once to let lazy.nvim install plugins from `lazy-lock.json`.
