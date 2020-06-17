#!/sbin/sh

ui_print "Mounting partitions . . ."
if mount /system; then
	exit 0
fi

# Check A/B slot
SLOT=`grep_cmdline androidboot.slot_suffix`
if [ -z $SLOT ]; then
	SLOT=`grep_cmdline androidboot.slot`
	[ -z $SLOT ] || SLOT=_${SLOT}
fi
[ -z $SLOT ] || ui_print "- Current boot slot: $SLOT"

# Mount ro partitions
mount_ro_ensure "system$SLOT app$SLOT" /system
if [ -f /system/init.rc ]; then
	SYSTEM_ROOT=true
	setup_mntpoint /system_root
	if ! mount --move /system /system_root; then
		umount /system
		umount -l /system 2>/dev/null
		mount_ro_ensure "system$SLOT app$SLOT" /system_root
	fi
	mount -o bind /system_root/system /system
else
	grep ' / ' /proc/mounts | grep -qv 'rootfs' || grep -q ' /system_root ' /proc/mounts \
	&& SYSTEM_ROOT=true || SYSTEM_ROOT=false
fi
