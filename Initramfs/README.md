## Initramfs Project for Linux From Scratch

Once create_initramfs.sh is made
```
cd /zbuild/initramfs
mv -v init.sh init
chmod +x init
find . -print0 | cpio --null -H newc -o | xz --check=crc32 -9 > ../initrd.img
```
Create a grub-root layout
```
mkdir -pv /zbuild/grub-root/boot/grub
cp -v grub.cfg /zbuild/grub-root/boot/grub
cp -v initrd.img /zbuild/grub-root/boot
cp -v vmlinuz /zbuild/grub-root/boot
cp -v lfs-root.squashfs /zbuild/grub-root/boot
```
Create iso image file
```
cd /zbuild
grub-mkrescue -o lfs-dvd.iso grub-root
```
Simple Qemu Test
```
qemu-system-x86_64 -enable-kvm -m 4G -cdrom lfs-dvd.iso -boot d -serial mon:stdio -vga qxl

qemu-system-x86_64 -enable-kvm -m 8G -cdrom lfs-dvd.iso -boot d -serial mon:stdio -vga qxl \
 -netdev user,id=net0,hostfwd=tcp::2020-:22 -device virtio-net-pci,netdev=net0
```
