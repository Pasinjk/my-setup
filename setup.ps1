#Requires -Version 5.1
<#
Symlinks this repo's configs into place. Re-run anytime; existing real files/dirs
at the target are backed up once (with a .bak-<timestamp> suffix), existing
symlinks are just replaced.

Creating a symlink needs either Developer Mode on (Settings > Update & Security >
For developers) or an elevated (Run as Administrator) shell.
#>

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Link($target, $link) {
    if (Test-Path $link) {
        $item = Get-Item $link -Force
        if ($item.LinkType) {
            Remove-Item $link -Force -Recurse
        } else {
            $backup = "$link.bak-$(Get-Date -Format yyyyMMddHHmmss)"
            Write-Host "Backing up existing $link -> $backup"
            Rename-Item $link $backup
        }
    } else {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $link) | Out-Null
    }
    New-Item -ItemType SymbolicLink -Path $link -Target $target | Out-Null
    Write-Host "Linked $link -> $target"
}

Link "$root\nvim"          "$env:LOCALAPPDATA\nvim"
Link "$root\wezterm\wezterm.lua" "$env:USERPROFILE\.wezterm.lua"
