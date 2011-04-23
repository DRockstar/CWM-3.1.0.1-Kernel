#!/system/bin/sh
# DRockstar Clean Kernel recovery.sh called from recovery.rc and fota.rc

/sbin/busybox mount -o remount,rw / /

# Fix permissions in /sbin, just in case
/sbin/busybox chmod 755 /sbin/*
/sbin/busybox chmod 06755 /sbin/su

# Install busybox to /sbin
/sbin/busybox --install -s /sbin

# Fix screwy ownerships
for blip in conf default.prop fota.rc init init.goldfish.rc init.rc init.smdkc110.rc lib lpm.rc modules recovery.rc res sbin
do
        chown root.system /$blip
        chown root.system /$blip/*
done

chown root.system /lib/modules/*
chown root.system /res/images/*

/sbin/mount -o remount,ro / /

mount /dev/block/stl9 /system
mount /dev/block/stl10 /data
mount /dev/block/stl11 /cache
for test in system data cache
do
	eval t$test="`mount|awk /$test/'{print $5}'`"
done

if [ "$tsystem" = "rfs" ] && [ "$tdata" = "rfs" ] && [ "$tcache" = "rfs" ]; then
	/sbin/recovery
else
	/system/bin/recovery
fi




