# Dotfiles

Personal dotfiles for configuring [Omarchy](https://omarchy.org/).

I don't recommend copying everything across as I remap a lot of keybinds.

## Install dependencies

Run:

```bash
./scripts/omarchy-extras
```

The dependencies it adds:

- fish: faster startup, and better completions
- keyd: rebinds keys and works across wayland / X11 apps
- google-chrome: used instead of chromium to share bookmarks across different platforms
- uv: very fast python version, package, and tool manager

## Hyperland

Window management keybindings are remapped to be vi style e.g. `SUPER+h = focus window left`, and workspaces are assigned to more easily accessible keys e.g. `i o p`. See [.config/hypr/bindings.conf](.config/hypr/bindings.conf) for all remappings.

Repeat delay/rate is greatly reduced/increased in [.config/hypr/input.conf](.config/hypr/input.conf). This may be too fast for you, so modify as required.

## Fish

The default shell remains as bash to not conflict with anything Omarchy provides, but when starting alacritty it uses fish.

It uses fisher to add `nvm` for node version management, and `z` for the same quick `cd` functionality as Omarchy bash.

It adds a prompt that shows git branch, vi mode indicator, and time it took previous command to run, without using starship.

There are aliases to match Omarchy functionality from bash, but there are more aliases which are likely not relevant to you.

Relevant files:

- [.config/fish/config.fish](.config/fish/config.fish): the main config file with aliases etc.
- [.config/alacritty/alacritty.toml](.config/alacritty/alacritty.toml): uses fish as default shell
- [.config/fish](.config/fish): the rest of the files contain functionality required for fisher, z, and nvm

## Supercaps

To bind capslock to another layer, configure example at [~/supercaps.conf](./supercaps.conf) to your liking, then run:

```bash
./scripts/supercaps
```

## Lazyvim

Many personal keybindings here that you likely won't want, but has things such as [multicursor](.config/nvim/lua/plugins/multicursor.lua) setup. All keybindings are in [.config/nvim/lua/config/keymaps.lua](.config/nvim/lua/config/keymaps.lua).

## Neovim Server

Fish is set up to always open files in a nvim session if one is active, otherwise create one. Works from alacritty and nvim terminal.

You can also enable an alacritty `ctrl+shift+alt+o` hotkey to open a displayed file in the active nvim session. You have to link the script to a path where alacritty can find it: `sudo ln -s scripts/nvim-remote-open /usr/bin/nvim-remote-open`.

Relevant files:

- [.config/fish/config.fish](.config/fish/config.fish): use a single nvim session, files open in the active session. Save directory path when navigating from nvim terminal.
- [.config/alacritty/alacritty.toml](.config/alacritty/alacritty.toml): has a regex for selecting files, opens the file using the `nvim-remote-open` script.
- [scripts/nvim-remote-open](scripts/nvim-remote-open): script called from alacritty to pass the current directory, filename, line and col number to the active nvim server.

## Dual boot Omarchy and Windows 11 on two hard drives

See guide in [dual-boot-omarchy-windows.md](dual-boot-omarchy-windows.md), you need two separate hard drives to avoid manual setup not covered in the guide.

## Ubuntu and macos

Dotfiles can also work across macos and remote instances of ubuntu, many files are ignored but you can install dependencies such as fish and fd with:

```bash
./scripts/ubuntu-extras
```

Setup script for macos not there yet so install dependencies manually with brew.

To get latest nvim prebuilt binary compatible with lazyvim run:

```bash
./scripts/nvim-ubuntu-macos
```

Both brew and apt install a version that isn't fully compatible with Lazyvim.

