# Debian installation

## Console

Use urxvt:
* Install ```rxvt-unicode-256color``` (we want the 256 colors !)
* Launch with rxvt-unicode

Configuration example (Spacemacs-themed) in ~/.Xdefaults:
```
! Restore Ctrl+Shift+(c|v)
URxvt.keysym.Shift-Control-V: eval:paste_clipboard
URxvt.keysym.Shift-Control-C: eval:selection_to_clipboard
URxvt.iso14755: false
URxvt.iso14755_52: false

URxvt*scrollBar: False
! URxvt*background: black
! URxvt*foreground: white

URxvt.font: xft:DejaVu Sans Mono:size=11
URxvt.boldfont: xft:DejaVu Sans Mono:bold:size=11

!! Colorscheme

! special
*.foreground: #b2b2b2
*.background: #292b2e
*.cursorColor: #e3dedd
! black
*.color0: #292b2e
*.color8: #292b2e
! red
*.color1: #f2241f
*.color9: #f2241f
! green
*.color2: #67b11d
*.color10: #67b11d
! yellow
*.color3: #b1951d
*.color11: #b1951d
! blue
*.color4: #4f97d7
*.color12: #4f97d7
! magenta
*.color5: #a31db1
*.color13: #a31db1
! cyan
*.color6: #28def0
*.color14: #28def0
! white
*.color7: #b2b2b2
*.color15: #b2b2b2
```
 
## Drivers

Wifi:
* Install ```network-manager```
* Install ```firmware-realtex``` (drivers)
* ```nmcli device wifi connect myessid password mypasswd```

Add to /etc/default/grub (tty resolution issues with Nvidia proprietary drivers):
```
GRUB_GFXMODE=1920x1080
GRUB_GFXPAYLOAD_LINUX=keep
```

Usb mounting with ```usbmount```:
* package created from https://github.com/rbrito/usbmount
* ```for f in /media/usb*; do echo "$f"; ls "$f"; done```
* ```FILESYSTEMS="vfat ext2 ext3 ext4 hfsplus ntfs exfat"``` in ```/etc/usbmount/usbmount.conf```
