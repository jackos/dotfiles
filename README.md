# Dotfiles

Personal dotfiles with a focus on configuring [omarchy](https://omarchy.org/).

## Install dependencies

Run:

```bash
./scripts/omarchy-extras.sh
```

The dependencies it adds:

- fish: faster startup, and better completions
- keyd: rebinds keys and works across wayland / X11 apps
- google-chrome: share bookmarks across different OS's
- uv: very fast python version, package, and tool manager

## Hyperland

Window management keybindings are remapped to be vi style e.g. `SUPER+h = focus window left`. see [~/.config/hypr/bindings.conf](./.config/hypr/bindings.conf) for all remappings.

Repeat delay is greatly reduced and repeat rate is greatly increased in [~/.config/hypr/input.conf](./.config/hypr/input.conf). This may be too fast for you, so modify as required.

Startup script at [.config/hypr/autostart.conf](./.config/hypr/autostart.conf) restarts the `iwd` network daemon on startup as I often have to do this manually.

## Fish

The default shell still remains as bash to not conflict with anything omarchy provides, but when starting alacritty it uses fish.

Lazyvim continues to use bash for shell functionality.

It uses fisher to add nvm for node version management, and z for the same quick `cd` functionality as omarchy bash.

The config has aliases to match omarchy on bash, and some which may not be relevant to you.

It also adds a prompt that shows git branch, vi mode indicator, and time it took previous command to run, without using starship.

Relevant files:

- [~/.config/fish](./.config/fish)
- [~/.config/alacritty/alacritty.toml](./.config/alacritty/alacritty.toml)

## Supercaps

To bind capslock to another layer, configure example at [~/supercaps.conf](./supercaps.conf) to your liking, then run:

```bash
./scripts/supercaps.sh
```

## Lazyvim

Many personal keybindings here that you likely won't want, but adds [multicursor](./.config/nvim/lua/plugins/multicursor.lua) and a [diff selector](./.config/nvim/lua/plugins/snacks.lua) for current file historic git changes with `<space>gf`. Plugin keybinding examples are in [.config/nvim/lua/config/keymaps.lua](./.config/nvim/lua/config/keymaps.lua)

## Ubuntu and macos

Designed to also work across remote instances of ubuntu and macos, many files are ignored but you can install dependencies such as fish and fd with:

```bash
./scripts/ubuntu-extras.sh
```

Setup script for macos not there yet so install dependencies manually with brew.

To get latest nvim prebuilt binary compatible with lazyvim run:

```bash
./scripts/nvim-ubuntu-macos.sh
```

Both brew and apt install a version that isn't fully compatible.

