#!/sbin/sh

ui_print "Unmounting partitions . . ."
umount -l /system
umount -l /system_root

for DIR in /system /system_root; do
	if [ -L "${DIR}_link" ]; then
		rmdir $DIR
		mv -f ${DIR}_link $DIR
	fi
done

exit 1
