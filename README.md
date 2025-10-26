# Dotfiles

Personal dotfiles for [Omarchy](https://omarchy.org/) that also work with macos, base arch, and remote ubuntu instances.

I don't recommend copying everything across as I remap a lot of keybinds.

## Install dependencies

This will remove omarchy dependencies that aren't required, and install some new dependencies.

See [scripts/arch-deps](scripts/arch-deps) for descriptions of both omarchy dependencies and my personal additions, you can configure this and remove things you don't want.

Also see [scripts/omarchy-remove-deps](scripts/omarchy-remove-deps) for things I don't require from omarchy, configure this as well to avoid removing what you want to keep.

If you're happy with both you can run:

```bash
./scripts/omarchy-extras
```
## Hyperland

Window management keybindings are remapped to be vi style e.g. `SUPER+h = focus window left`, and workspaces are assigned to more easily accessible keys e.g. `i o p`. See [.config/hypr/bindings.conf](.config/hypr/bindings.conf) for all remappings.

Repeat delay/rate is greatly reduced/increased in [.config/hypr/input.conf](.config/hypr/input.conf). This may be too fast for you, so modify as required.

## Fish

The default shell remains as bash to not conflict with anything Omarchy provides, but when starting alacritty it uses fish.

It uses fisher to add `nvm` for node version management, and `z` for the same quick `cd` functionality as Omarchy bash.

It adds a prompt that shows git branch, vi mode indicator, and time it took previous command to run, without using starship.

There are aliases to match Omarchy functionality from bash.

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

Both brew and apt by default install a version that isn't fully compatible with Lazyvim.

