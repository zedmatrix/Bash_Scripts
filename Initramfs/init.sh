#!/bin/sh
PATH=/usr/bin:/usr/sbin
export PATH
insmod /usr/lib/hfs.ko
insmod /usr/lib/hfsplus.ko

problem() {
    printf "Encountered: %s \n\nDropping you to a shell.\n\n" "$*"
    export PATH=/usr/bin:/usr/sbin
    exec </dev/console >/dev/console 2>&1
    exec /bin/sh
}

# Mount essential filesystems
mount -n -t devtmpfs devtmpfs /dev
mount -n -t proc     proc     /proc
mount -n -t sysfs    sysfs    /sys
mount --mkdir -t tmpfs tmpfs /run
mount --mkdir -t devpts devpts /dev/pts -o gid=5,mode=620
mount --mkdir -t tmpfs tmpfs /dev/shm
mount --mkdir -t cgroup2 none /sys/fs/cgroup
[ ! -d /run/lock ] && mkdir -p /run/lock

# Start udev
/sbin/udevd --daemon
udevadm trigger
udevadm settle

# Detect rd.live.ram=1
read -r cmdline < /proc/cmdline
echo "$cmdline" | grep -q 'rd.live.ram=1' && COPYTORAM=1

echo "Locating boot media..."
label="LFSLIVE_2025"
mntroot=""
max_wait=30
waited=0

while [ -z "$mntroot" ] && [ "$waited" -lt "$max_wait" ]; do
    mntroot=$(blkid -t LABEL="$label" -o device | grep '^/dev/s' | head -n1)
    if [ -z "$mntroot" ]; then
        sleep 1
        waited=$((waited + 1))
    fi
done

if [ -n "$mntroot" ]; then
    mount -o ro "$mntroot" /mnt/cdrom
else
    problem "Cannot locate device with LABEL=$label"
fi

mountpoint -q /mnt/cdrom || problem "Cannot Mount Filesystem on LABEL=$label"


SQUASH=$(find /mnt/cdrom -maxdepth 1 -type f -name '*.squashfs' | head -n 1)
[ -z "$SQUASH" ] && problem "No squashfs image found on /mnt/cdrom"

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
for mnt in /proc /sys /dev /run /dev/pts /dev/shm /sys/fs/cgroup; do
    if mountpoint -q "$mnt"; then
        mkdir -p "/mnt/merged$mnt"
        echo "Moving mount $mnt"
        mount --move "$mnt" "/mnt/merged$mnt" || problem "Failed to move $mnt"
    else
        echo "$mnt not mounted, skipping"
    fi
done

if [ ! -x /mnt/merged/sbin/init ]; then
  problem "/sbin/init not found or not executable in new root"
fi
exec switch_root /mnt/merged /sbin/init
