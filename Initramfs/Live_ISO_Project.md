# Creating a Live ISO for CD/DVD/USB Project

## Initialization of rootfs for squashfs
using qemu:`qemu-img create lfs-stable.img 32G`<br>
temporary drive: `qemu-img create lfs-temp.img 10G`

Build your Linux From Scratch system to chapter 10 including extra utilities.
This is where you can exit just like the instructions in chapter 7 - saving the system.

## Saving rootfs
`logout` from your build chroot.<br>
If the temporary drive is not formatted: `mkfs -v -t ext4 /dev/sdb1`
```
mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}

export LFS=/mnt/lfs
export USB=/mnt/usb
mount -v -t ext4 /dev/sdb1 $USB
cd $LFS
tar --exclude='/sources' --exclude='/boot' -cJpf $USB/lfs-rootfs-12.3.tar.xz .
```

## Building Squashfs Tools
```
01_squashfs-tools-4.6.1
02-libisofs-1.5.6
03_libburn-1.5.6
04_libisoburn-1.5.6
05_mtools-4.0.48
```
Grub For UEFI is recommended.
## Building SquashFS from rootfs.tar
```
export USB=/mnt/usb
cd $USB
mkdir -pv $USB/squashfs-root
tar -xpf $USB/lfs-rootfs-12.3.tar.xz -C squashfs-root
```
### System-V Init 
Should be removed or just remarked: `$USB/squashfs-root/etc/fstab` <br>
These startup services may need to be moved or removed, they conflict with the initramfs overlayfs
```
cd $USB/squashfs-root/etc/rc.d/rcS.d
mkdir -v disabled
mv -v S00mountvirtfs S20swap S30checkfs S40mountfs S45cleanfs S05modules disabled/

cd $USB
mksquashfs squashfs-root lfs-live.squashfs -comp xz
```
