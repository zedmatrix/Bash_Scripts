#!/bin/sh
PATH=/usr/bin:/usr/sbin
export PATH

problem() {
   printf "Encountered: %s \n\nDropping you to a shell.\n\n" "$*"
   export PATH=/usr/bin:/usr/sbin
   exec sh
}

# Mount essential filesystems
mount -n -t devtmpfs devtmpfs /dev
mount -n -t proc     proc     /proc
mount -n -t sysfs    sysfs    /sys
sleep 2

read -r cmdline < /proc/cmdline

# Detect rd.live.ram=1
echo "$cmdline" | grep -q 'rd.live.ram=1' && COPYTORAM=1

# Mount CD-ROM
mount -t iso9660 /dev/sr0 /mnt/cdrom || problem "Failed to mount /dev/sr0"
sleep 2

# Load modules (if needed)
modprobe loop 2>/dev/null || insmod /usr/lib/loop.ko
modprobe overlay 2>/dev/null || insmod /usr/lib/overlay.ko

# Find squashfs image
SQUASH=$(find /mnt/cdrom -maxdepth 1 -type f -name '*.squashfs' | head -n 1)
[ -z "$SQUASH" ] && problem "No squashfs image found on /cdrom"

# If rd.live.ram=1, copy to tmpfs
if [ "$COPYTORAM" = "1" ]; then
    echo "Copying $SQUASH to RAM..."
    mkdir -p /mnt/ramdisk
    mount -t tmpfs -o size=2G tmpfs /mnt/ramdisk || problem "Failed to mount tmpfs"
    cp "$SQUASH" /mnt/ramdisk/image.squashfs || problem "Failed to copy squashfs to RAM"
    SQUASH=/mnt/ramdisk/image.squashfs
fi

# Mount squashfs
mkdir -p /mnt/lower
mount -o loop "$SQUASH" /mnt/lower || problem "Failed to mount $SQUASH"

# Set up overlay
mount -t tmpfs tmpfs /mnt/overlay
mkdir -p /mnt/overlay/upper /mnt/overlay/work /mnt/merged
mount -t overlay overlay -o \
  lowerdir=/mnt/lower,upperdir=/mnt/overlay/upper,workdir=/mnt/overlay/work \
  /mnt/merged || problem "Failed to mount overlay"

# Move mounts and switch root
echo "Switching to overlay root..."
mount --move /proc /mnt/merged/proc
mount --move /sys  /mnt/merged/sys
mount --move /dev  /mnt/merged/dev
exec switch_root /mnt/merged /sbin/init
