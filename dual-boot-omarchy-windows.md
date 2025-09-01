# Dual boot Omarchy with Windows 11 on two hard disks

If you have an existing Windows 11 installation on one hard disk, and you install Omarchy on a different hard disk using the provided [ISO](https://learn.omacom.io/2/the-omarchy-manual/50/getting-started), it may wipe out the boot entry for Windows.

The easiest way to resolve this is with a bootable Windows 11 USB to recreate the boot entry and populate your existing EFI partition mounted to `/boot` in Omarchy. Skip the first step if you already have a bootable Windows 11 USB.

## Create bootable Windows 11 ISO

Go to [https://www.microsoft.com/en-us/software-download/windows11](https://www.microsoft.com/en-us/software-download/windows11) and scroll down to the bottom where it says `Download Windows 11 Disk Image ISO for x64 devices`. Select Windows 11 and press confirm, select language and press confirm, then click `64-bit Download`.

This will download something similar to: `Win11_24H2_English_x64.iso`

If you already have a preferred way to make a USB bootable from Linux use that, otherwise Ventoy is a great tool to add multiple bootable ISO's to a single USB.

First identify the USB drive:

```bash
sudo fdisk -l
```

Which should show something like:

```plaintext
Disk /dev/sda: 931.88 GiB, 1000593162240 bytes, 1954283520 sectors
Disk model: SanDisk 3.2 Gen1
```

Then install Ventoy to your USB:

```bash
yay -S ventoy-bin
sudo ventoy -i /dev/sda # replace sda with your USB drive
```

Now you can simply copy ISO's into your USB drive:

```bash
sudo mount -m /dev/sda1 /mnt/ventoy-usb # replace sda with your USB drive

cp ~/Downloads/Win11_24H2_English_x64.iso /mnt/ventoy-usb/

# Optionally copy the Omarchy ISO in there as well
cp ~/Downloads/omarchy-online.iso /mnt/ventoy-usb/
```

That's it, you now have a bootable USB that can boot whichever ISO's you add. You're also able to copy drivers into the drive if desired.

## Generate Windows 11 EFI files and populate boot entry

Plug in your bootable USB and enter the BIOS on your system (e.g. repeatably press F2 during system boot) and move the USB to the top of the boot priority. Then restart and during boot select Windows 11 (if using ventoy select normal mode).

Once the Windows 11 install screen shows up press Shift+F10 to enter a command prompt.

Enter diskpart to identify the correct partitions.

The EFI boot partition you're looking for as of writing is 2048 MB and the `Type`  is `System`.

The Windows partition you're looking for something that's multiple GB's and the `Type` is `Primary`:

__WARNING: the disk numbers may not be in the order you expect!__

```bat
diskpart
list disk

select disk 0
list partition

select disk 1
list partition

select disk 2
list partition
```

Continue listing partitions for all your disks.

Once you identify your EFI partition e.g. if it's on disk 1 partition 1, assign a drive letter to it:

```bat
select disk 1
select partition 1
assign letter=Z
```

Then assign a letter to your Windows partition, for example:

```bat
select disk 0
select partition 2
assign letter=W
```

Now exit diskpart:

```bat
exit
```

Then create the boot entry and populate the EFI partition with Windows EFI files:

```bat
bcdboot W:\Windows /s Z: /f UEFI
```

You can confirm the files were generated correctly with:

```bat
dir Z:\EFI\Microsoft\Boot\
```

You should see many files in there, along with the `bootmgfw.efi`.

Now reboot, first enter `exit` from the command prompt, then press the `X` in the top right to reboot.

During boot enter the bios (e.g. repeatably press F2) and put Limine back to the top of the boot priority (The one that just says Limine).

## Add Windows 11 to Limine

Boot back into Omarchy.

Now that the Windows is back in the boot entries, Limine makes it very simple to add it:

```bash
sudo limine-scan
sudo limine-install
```

You can confirm it worked with e.g. `sudo nvim /boot/limine.conf`, and change the priority and label in there if desired.

Restart the computer and you'll now be able to boot into both Omarchy and Windows.

