INITDIR=/zbuild/initramfs

printf "Creating Initramfs Directory Layout"

mkdir -pv $INITDIR/{dev,proc,sys,run} 
mkdir -pv $INITDIR/usr/{bin,lib,sbin} 
mkdir -pv $INITDIR/mnt/{cdrom,ramdisk}
mkdir -pv $INITDIR/mnt/overlay/{upper,lower,work}
mkdir -pv $INITDIR/mnt/merged/{proc,dev,sys}

mknod -m 622 $INITDIR/dev/console c 5 1
mknod -m 666 $INITDIR/dev/null    c 1 3
mknod -m 666 $INITDIR/dev/zero    c 1 5
mknod -m 666 $INITDIR/dev/tty     c 5 0
mknod -m 666 $INITDIR/dev/sr0     b 11 0
mknod -m 666 $INITDIR/dev/loop0   b 7 0

for i in bin lib sbin; do
  ln -sv usr/$i $INITDIR/$i
done

case $(uname -m) in
  x86_64) mkdir -pv $INITDIR/lib64 ;;
esac

printf "Copying Files and Libraries For Temporary System"
cp -v $(find /usr/lib -name 'overlay.ko' | head -1) $INITDIR/usr/lib
cp -v $(find /usr/lib -name 'loop.ko' | head -1) $INITDIR/usr/lib

copy_libs() {
  for bin in "$@"; do
    echo "Inspecting $bin"
    ldd "$bin" | awk '/=>/ {print $3} /ld-linux/ {print $1}' | while read lib; do
      [ -e "$lib" ] && cp -v --parents "$lib" "$INITDIR"
    done
  done
}

binfiles="sh cat cp killall ls mkdir mknod mount "
binfiles="$binfiles umount sed sleep ln rm uname"
binfiles="$binfiles readlink basename head grep find "
for bin in $binfiles; do
  cp -v /bin/$bin $INITDIR/usr/bin/ || cp -v /usr/bin/$bin $INITDIR/usr/bin/
  copy_libs /usr/bin/$bin
done

sbinfiles="modprobe insmod blkid switch_root"
for sbin in $sbinfiles; do
  cp -v /sbin/$sbin $INITDIR/usr/sbin/ || cp -v /usr/sbin/$sbin $INITDIR/usr/sbin/
  copy_libs /usr/sbin/$sbin
done

