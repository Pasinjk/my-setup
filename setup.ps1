#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
Symlinks this repo's configs into place. Run with `pwsh ./setup.ps1` on
Windows, Linux, or macOS (PowerShell 7+ is cross-platform).

Re-run anytime; existing real files/dirs at the target are backed up once
(with a .bak-<timestamp> suffix), existing symlinks are just replaced.

Windows only: creating a symlink needs either Developer Mode on (Settings >
Update & Security > For developers) or an elevated (Run as Administrator)
shell. Linux/macOS need no special privilege for a symlink under $HOME.
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

if ($IsWindows) {
    $nvimTarget = Join-Path $env:LOCALAPPDATA "nvim"
    $weztermTarget = Join-Path $env:USERPROFILE ".wezterm.lua"
} else {
    $configHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { "$HOME/.config" }
    $nvimTarget = Join-Path $configHome "nvim"
    $weztermTarget = Join-Path $HOME ".wezterm.lua"
}

Link (Join-Path $root "nvim") $nvimTarget
Link (Join-Path $root "wezterm/wezterm.lua") $weztermTarget
