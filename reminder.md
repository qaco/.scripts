# Debian installation

## Tty

Add to /etc/default/grub:
```
GRUB_GFXMODE=1920x1080
GRUB_GFXPAYLOAD_LINUX=keep
```

## Wifi

Use ```ncmli```:
* Install ```network-manager```
* Install ```firmware-realtex``` (drivers)
* ```nmcli device wifi connect myessid password mypasswd```

## Usb mounting

Using ```usbmount```:
* package created from https://github.com/rbrito/usbmount
* ```for f in /media/usb*; do echo "$f"; ls "$f"; done```
* ```FILESYSTEMS="vfat ext2 ext3 ext4 hfsplus ntfs exfat"``` in ```/etc/usbmount/usbmount.conf```
