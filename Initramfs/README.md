## Initramfs Project for Linux From Scratch

### Creating SquashFS
```
cd /zbuild
mount -v /dev/sdb3 /mnt/lfs
mksquashfs /mnt/lfs lfs-root.squashfs -comp xz -Xbcj x86 -e boot sources zbuild
```
### Testing SquashFS
```
LFS=/mnt/squash-root
mkdir -v $LFS
mount-vkfs.sh
mount -v lfs-root.squashfs $LFS -t squashfs -o loop
chroot $LFS /bin/bash
```

### Compressing initrd.img from create_initramfs.sh
```
cd /zbuild/initramfs
mv -v init.sh init
chmod +x init
find . -print0 | cpio --null -H newc -o | xz --check=crc32 -9 > ../initrd.img
```

### Create a grub-root layout
```
mkdir -pv /zbuild/grub-root/boot/grub
cp -v grub.cfg /zbuild/grub-root/boot/grub
cp -v /boot/vmlinuz /zbuild/grub-root/boot
cp -v /zbuild/initrd.img /zbuild/grub-root/boot
cp -v /zbuild/lfs-root.squashfs /zbuild/grub-root/boot
```

### Create iso image file
```
cd /zbuild
grub-mkrescue -o lfs-dvd.iso grub-root
```

### Simple Qemu Test
```
qemu-system-x86_64 -enable-kvm -m 4G -cdrom lfs-dvd.iso -boot d -serial mon:stdio -vga qxl

qemu-system-x86_64 -enable-kvm -m 8G -cdrom lfs-dvd.iso -boot d -serial mon:stdio -vga qxl \
 -netdev user,id=net0,hostfwd=tcp::2020-:22 -device virtio-net-pci,netdev=net0
```
