# Omarchy Dotfiles

Personal dotfiles to configure [omarchy](https://omarchy.org/).

If you want to pick and choose what to grab, you can clone repo into current directory
without checking out files:

```bash
git clone --no-checkout  git@github.com:jackos/dotfiles .
```


## Supercaps

To bind capslock to another layer, configure example at supercaps.conf to
your liking, then:

```bash
sudo pacman -Syuu keyd
ln -s ~/supercaps.conf /etc/keyd/default.conf
sudo keyd reload
```
```
```
