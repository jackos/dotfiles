# Dotfiles

Personal dotfiles that work across arch, ubuntu remote instances, and macos.

Took themes and scripts from [Omarchy](https://omarchy.org/), there's a LICENCE in the repo for that.

I don't recommend copying everything across as I remap a lot of keybindings.

## Install dependencies

Install paru which is a AUR helper:

```bash
cd ~/.local
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

Remove whatever you don't want in [scripts/arch-deps](scripts/arch-deps), then install the rest with:

```bash
sed '/^#/d;/^$/d' scripts/arch-deps | paru -Syuu --needed -
```

## Hyperland

Window management keybindings are mapped to be vi style e.g. `SUPER+h = focus window left`, and workspaces are assigned to more easily accessible keys e.g. `i o p`. See [.config/hypr/bindings.conf](.config/hypr/bindings.conf) for all remappings.

## Supercaps

To bind capslock to another layer, configure example at [~/supercaps.conf](./supercaps.conf) to your liking, then run:

```bash
./scripts/supercaps
```

## Lazyvim

Many personal keybindings here that you likely won't want, but has things such as [multicursor](.config/nvim/lua/plugins/multicursor.lua) setup. All keybindings are in [.config/nvim/lua/config/keymaps.lua](.config/nvim/lua/config/keymaps.lua).

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
