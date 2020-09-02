#!/sbin/sh

for SYSTEM_MOUNT in '/system' '/system/system' '/system_root' '/system_root/system'
do
  if ! [ -d "$SYSTEM_MOUNT/addon.d" ]
	then
		mkdir -p $SYSTEM_MOUNT/addon.d
		chmod -R 0755 "$SYSTEM_MOUNT/addon.d"
	else
		echo "Patching addon.d Camera2 API..."
		if [ -f "$SYSTEM_MOUNT/addon.d/34-camera.sh" ]
		  then
			  sed -i 's+	  echo "persist.vendor.camera.HAL3.enabled=1" >> /system/build.prop+	  echo "persist.vendor.camera.HAL3.enabled=1" >> /system/build.prop\n	  echo "persist.camera.HAL3.enabled=1" >> /system/build.prop\n	  echo "persist.camera.eis.enable=1" >> /system/build.prop+g' $SYSTEM_MOUNT/addon.d/34-camera.sh 2>&1
			  if [ $? -eq 1 ]
				then
					echo "ERROR:  /system is read-only mode."
					exit 1
				fi
		  else
			  echo "ERROR:  /system not yet mounted."
			  exit 1
		  fi
	fi

  if ! [ -f "$SYSTEM_MOUNT/build.prop" ]
	then
		echo "ERROR:  /system not yet mounted."
		exit 1
	else
		if cat $BUILD_PROP
		  then
			  BUILD_PROP="$SYSTEM_MOUNT/build.prop"
		  else
			  echo "ERROR:  /system is read-only mode."
			  exit 1
		  fi
	fi
done

echo "Patching /system/build.prop Camera2 API..."
for SCRIPT_PROP in 'persist.vendor.camera.HAL3.enabled=1' 'persist.camera.HAL3.enabled=1' 'persist.camera.eis.enable=1'
do
  cat $BUILD_PROP 2>&1 | grep ^$SCRIPT_PROP$ >/dev/null
  if [ $? -eq 1 ]
	then
		exit 1
	fi
done
cat $BUILD_PROP 2>&1 | grep ^persist.vendor.camera.HAL3.enabled=1$ >/dev/null
if [ $? -eq 1 ]
  then
	  sed -i 's+#Enable Camera2 API\npersist.vendor.camera.HAL3.enabled=1+#Enable Camera2 API\npersist.vendor.camera.HAL3.enabled=1\npersist.camera.HAL3.enabled=1\npersist.camera.eis.enable=1+g' $BUILD_PROP 2>&1
	  if [ $? -eq 1 ]
		then
			echo "ERROR:  /system is read-only mode."
			exit 1
		fi
  fi

for SCRIPT_PROP in 'persist.vendor.camera.HAL3.enabled' 'persist.camera.HAL3.enabled' 'persist.camera.eis.enable'
do
  getprop $SCRIPT_PROP 2>&1 | grep 1 >/dev/null
  if [ $? -eq 1 ]
	then
		setprop $SCRIPT_PROP 1
	fi
done

exit 0
