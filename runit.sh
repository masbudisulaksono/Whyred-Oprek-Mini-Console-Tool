#!/bin/bash

# Whyred Oprek Mini Console Tool for Linux
# ========================================
#
#
# Created by:     Faizal Hamzah
#                 The Firefox Flasher - The Firefox Foundation
# Created time:   June 14, 2020   10:34pm
# Modified time:  June 22, 2020   4:07am
#
#
# Description:
# This program was written and created by Faizal Hamzah with the aim of making
# it easier for users to do the work of modifying Android mobile devices.
#
# Facilities of this program, include:
#   1.  Check the status bootloader
#   2.  Flash TWRP
#   3.  Flash LazyFlasher
#   4.  Flash Camera2 API
#   5.  Flash Root Access
#
# This program is only for those who have a Xiaomi Redmi Note 5 Global/Pro
# phone (codename: Whyred)
#
# Special thanks:
# •  Google - Android
# •  TWRP team
# •  Orangefox team
# •  PitchBlack team
# •  Magisk team
# •  XDA
# •  Xiaomi Flashing Team
# •  and the users Xiaomi Redmi Note 5 Global/Pro



# begin the program

# Shortcut functions
# Main menu will need the shortcut for their option
# This is will running any execution and put to shortut
check-adb()
{
	echo "Checking ADB and Fastboot programs..."
	if ! [ -x $(command -v adb) ]
		then
			echo "$errorp  ADB and Fastboot not installed."
			adbfastboot_notfound=1
		fi
	if ! [ -x $(command -v fastboot) ]
		then
			echo "$errorp  ADB and Fastboot not installed."
			adbfastboot_notfound=1
	  fi
}

check-devices1()
{
	unset no_connection
	echo "Checking connection..."
	adb devices 2>&1 | grep "device\>"
	if [ $? -ne 0 ]
		then
			echo "$errorp  Your device not connected. Check the driver or USB debugging."
			while true
			do
				read -n1 -p "Try again? [Y/N] " yn
				echo
				case $yn in
					[Yy]* )	adb devices 2>&1 | grep "device\>"
							if [ $? -ne 0 ]; then
								echo "$errorp  Your device not connected. Check the driver or USB debugging."
								continue
							fi
							break
							;;
					[Nn]* )	no_connection=1
							if ! [ -z $reboot_recovery ]; then break; fi
							if ! [ -z $reboot_system ]; then break; fi
							if ! [ -z $reboot_bootloader ]; then break; fi
							break
							;;
					* )		continue
							;;
				esac
			done
		fi
	if ! [ -z $reboot_recovery ]; then recovery_adb=1; fi
	if ! [ -z $reboot_system ]; then reboot_adb=1; fi
	if ! [ -z $reboot_bootloader ]; then bootloader_adb=1; fi
}

check-devices2()
{
	unset no_connection
	echo "Checking connection..."
	adb devices 2>&1 | grep "recovery\>"
	if [ $? -ne 0 ]
		then
			echo "$errorp  Your device not connected in recovery. Check the driver or reboot recovery again."
			while true
			do
				read -n1 -p "Try again? [Y/N] " yn
				echo
				case $yn in
					[Yy]* )	adb devices 2>&1 | grep "recovery\>"
							if [ $? -ne 0 ]; then
								echo "$errorp  Your device not connected in recovery. Check the driver or reboot recovery again."
								continue
							fi
							break
							;;
					[Nn]* )	no_connection=1
							if ! [ -z $reboot_recovery ]; then break; fi
							if ! [ -z $reboot_system ]; then break; fi
							if ! [ -z $reboot_bootloader ]; then break; fi
							break
							;;
					* )		continue
							;;
				esac
			done
		fi
	if ! [ -z $reboot_recovery ]; then recovery_adb=1; fi
	if ! [ -z $reboot_system ]; then reboot_adb=1; fi
	if ! [ -z $reboot_bootloader ]; then bootloader_adb=1; fi
}

check-fastboot()
{
	unset no_connection
	echo "Checking fastboot connection..."
	fastboot $* devices 2>&1 | grep "fastboot\>"
	if [ $? -ne 0 ]
		then
			echo "$errorp  Your device not connected."
			no_connection=1
		fi
	if ! [ -z $reboot_recovery ]; then recovery_fastboot=1; fi
	if ! [ -z $reboot_system ]; then reboot_fastboot=1; fi
	if ! [ -z $reboot_bootloader ]; then bootloader_fastboot=1; fi
}

check-codename()
{
	echo "Checking require codename devices..."
	fastboot $* getvar product 2>&1 | grep "^product: *whyred"
	if [ $? -ne 0 ]
		then
			echo "$errorp  Your device is not Xiaomi Redmi Note 5/Pro. The code must 'whyred'."
			codename_false=1
	  fi
}

check-unlock()
{
	echo "Checking the device bootloader..."
	CURRENT_RESULT=true
	result=`fastboot $* oem device-info 2>&1 | grep "Device unlocked:" | cut -f 4 -d ' '`
	if [ -z "$result" ]; then result=false; fi
	if [ $result -ne $CURRENT_RESULT ]; then
		echo "$errorp  Your device locked bootloader."
	elif [ $result -eq $CURRENT_RESULT ]; then
		echo "$infop  Your device already unlocked bootloader."
	fi
}

check-antirollback()
{
	echo "Checking device antirollback version..."
	CURRENT_ANTI_VER=4
	arbver=`fastboot $* getvar anti 2>&1 | grep anti: | cut -f 2 -d ' '`
	if [ -z "$arbver" ]; then arbver=0; fi
	if [ $arbver -gt $CURRENT_ANTI_VER ]; then
		echo "$errorp  Current device antirollback version is greater than this package."
		largest_anti=1
	elif [ $arbver -eq $CURRENT_ANTI_VER ]; then
		fastboot $* flash antirbpass ./recovery/dummy.img
		if [ $? -ne 0 ]
			then
				echo "$errorp  Failed flash 'antirbpass'."
				error=1
			else
				echo "$infop  Flash 'antirbpass' success."
			fi
	  fi
}

flash-twrp()
{
	while true
	do
		clear
		echo
		echo "FLASH TWRP"
		echo "==========="
		echo
		echo
		echo "   1.)  Team Win Recovery Project"
		echo "   2.)  Orange Fox Recovery"
		echo "   3.)  PitchBlack Recovery Project"
		echo
		echo "   A.)  Let me choose"
		echo "   Q.)  Back to main menu"
		echo
		read -p "Select TWRP version: " aq123
		echo
		case $q123 in
			1 )		recoveryimg=./recovery/twrp.img
					break
					;;
			2 )		recoveryimg=./recovery/ofox.img
					break
					;;
			3 )		recoveryimg=./recovery/pbrp.img
					break
					;;
			[Aa]* )	while true; do
					echo "Type a img file (with directory if there in outside)"
					read -p ">" filename
					case $filename in
						$filename )	recoveryimg=$filename
									if ! [ -f $recoveryimg ]; then
										echo "Img file not found."
										continue
									fi
									break
									;;
						* )			continue
									;;
					esac; done
					;;
			[Qq]* )	twrp_exit=1
					break
					;;
			* )		continue
					;;
		esac
	done
}

check-sideload()
{
	echo "$cautionp  Before execution, select ADB Sideload first on recovery."
	read -n1 -srp "Press any key to continue..."
	echo
	adb devices 2>&1 | grep "sideload\>" 
	if [ $? -ne 0 ]
		then
			echo "$errorp  Your device not connected in sideload. Check the driver or reboot recovery again."
			while true
			do
				read -n1 -p "Try again? [Y/N] " yn
				echo
				case $yn in
					[Yy]* )	adb devices 2>&1 | grep "sideload\>"
							if [ $? -ne 0 ]; then
								echo "$errorp  Your device not connected in sideload. Check the driver or reboot recovery again."
								continue
							fi
							break
							;;
					[Nn]* )	no_connection=1
							break
							;;
					* )		continue
							;;
				esac
			done
	  fi
}

mount-system()
{
	>& /dev/null 2>&1 adb push ./data/mount-system.sh /tmp/mount-system.sh
	>& /dev/null 2>&1 adb push ./data/unmount-system.sh /tmp/unmount-system.sh
	echo "Mounting /system..."
	>& /dev/null 2>&1 adb shell '/sbin/busybox /tep/mount-system.sh'
	>& /dev/null 2>&1 adb shell '/sbin/sh /tmp/mount-system.sh'
	for s in /system /system/system
	do
		>& /dev/null 2>&1 adb pull $s/build.prop ./tmp/build.prop
	done
	if ! [ -f ./tmp/build.prop ]
		then
			echo "$errorp  /system not yet mounted."
			while true
			do
				read -n1 -p "Try again? [Y/N] " yn
				echo
				case $yn in
					[Yy]* )	>& /dev/null 2>&1 adb shell '/sbin/busybox /tmp/mount-system.sh'
							>& /dev/null 2>&1 adb shell '/sbin/sh /tmp/mount-system.sh'
							for s in /system /system/system; do
								>& /dev/null 2>&1 adb pull $s/build.prop ./tmp/build.prop
							done
							if ! [ -f ./tmp/build.prop ]; then
								echo "$errorp  /system not yet mounted."
								continue
							else
								rm -f ./tmp/build.prop
								break
							fi
							;;
					[Nn]* )	>& /dev/null 2>&1 adb shell '/sbin/busybox /tmp/unmount-system.sh'
							>& /dev/null 2>&1 adb shell '/sbin/sh /tmp/unmount-system.sh'
							not_mount=1
							break
							;;
					* )		continue
							;;
				esac
			done
		else
			rm -f ./tmp/build.prop
	 fi
}

write-prop()
{
	for s in /system /system/system
	do
		echo "Patching addon.d Camera2 API..."
		>& /dev/null 2>&1 adb shell 'mkdir $s/addon.d'
		>& /dev/null 2>&1 adb push ./data/cam2api_addon.sh $s/addon.d/34-camera.sh
		>& /dev/null 2>&1 adb shell 'chmod -R 0755 $s/addon.d'
		>& /dev/null 2>&1 adb shell 'chmod -R 0755 $s/addon.d/34-camera.sh'
		echo "Patching /system/build.prop Camera2 API..."
		>& /dev/null 2>&1 adb shell 'cat $s/build.prop' | grep "^persist.vendor.camera.HAL3.enabled=1"
		if [ $? -ne 0 ]; then
			>& /dev/null 2>&1 adb shell 'echo "persist.vendor.camera.HAL3.enabled=1" >> $s/build.prop'
		fi
		>& /dev/null 2>&1 adb shell 'setprop persist.vendor.camera.HAL3.enabled 1'
		>& /dev/null 2>&1 adb shell 'cat $s/build.prop' | grep "^persist.camera.HAL3.enabled=1"
		if [ $? -ne 0 ]; then
			>& /dev/null 2>&1 adb shell 'echo "persist.camera.HAL3.enabled=1" >> $s/build.prop'
		fi
		>& /dev/null 2>&1 adb shell 'setprop persist.camera.HAL3.enabled 1'
		>& /dev/null 2>&1 adb shell 'cat $s/build.prop' | grep "^persist.camera.eis.enable=1"
		if [ $? -ne 0 ]; then
			>& /dev/null 2>&1 adb shell 'echo "persist.camera.eis.enable=1" >> $s/build.prop'
		fi
		>& /dev/null 2>&1 adb shell 'setprop persist.camera.eis.enable 1'
	done
}

unmount-system()
{
	echo "Unmounting /system..."
	>& /dev/null 2>&1 adb shell '/sbin/busybox /tmp/unmount-system.sh'
	>& /dev/null 2>&1 adb shell '/sbin/sh /tmp/unmount-system.sh'
}

flash-root()
{
	while true
	do
		clear
		echo
		echo "INSTALL ROOT"
		echo "============="
		echo
		echo "   1.)  SuperSU"
		echo "   2.)  Magisk"
		echo
		echo "   Q.)  Back to main menu"
		echo
		read -p "Select TWRP version: " q12
		echo
		case $q12 in
			1 )		rootsel=SuperSU
					rootzip=./data/supersu.zip
					;;
			2 )		rootsel=Magisk
					rootzip=./data/magisk.zip
					;;
			[Qq]* ) root_exit=1
					break
					;;
			* )		continue
					;;
		esac
		echo "$cautionp  Before execution, select ADB Sideload first on recovery."
		read -n1 -srp "Press any key to continue..."
		echo
		adb devices 2>&1 | grep "sideload\>"
		if [ $? -ne 0 ]
			then
				echo "$errorp  Your device not connected. Check the driver or USB debugging."
				while true
				do
					read -n1 -p "Try again? [Y/N] " yn
					echo
					case $yn in
						[Yy]* )	adb devices 2>&1 | grep "sideload\>"
								if [ $? -ne 0 ]; then
									echo "$errorp  Your device not connected in sideload."
									continue
								fi
								break
								;;
						[Nn]* )	no_connection=1
								break
								;;
						* )		continue
								;;
					esac
				done
			fi
		case $q12 in
			1 )		break
					;;
			2 )		break
					;;
		esac
	done
}

reboot-recovery()
{
	if ! [ -z $recovery_adb ]
		then
			echo "Rebooting to recovery..."
			adb reboot recovery
			if [ $? -ne 0 ]; then
				echo "$errorp  Cannot boot to recovery."
			fi
		fi
	if ! [ -z $recovery_fastboot ]
		then
			if [ -z $recoveryimg ]; then
				echo "Booting to custom recovery..."
				recoveryimg=./recovery/ofox.img
			else
				echo "Rebooting to recovery..."
			fi
			fastboot $* boot $recoveryimg
			if [ $? -ne 0 ]; then
				echo "$errorp  Cannot boot to recovery."
			else
				echo "$infop  Download 'recovery' to 'boot' success."
			fi
	  fi
}

reboot-systemdevices()
{
	echo "Rebooting..."
	if ! [ -z $reboot_adb ]
		then
			adb reboot
			if [ $? -ne 0 ]; then
				echo "$errorp  Cannot reboot."
			fi
		fi
	if ! [ -z $reboot_fastboot ]
		then
			>& /dev/null 2>&1 fastboot $* reboot
			if [ $? -ne 0 ]; then
				echo "$errorp  Cannot reboot."
			fi
	  fi
}

reboot-bootloader()
{
	echo "Rebooting to bootloader..."
	if ! [ -z $bootloader_adb ]
		then
			adb reboot bootloader
			if [ $? -ne 0 ]; then
				echo "$errorp  Cannot reboot to bootloader."
			fi
		fi
	if ! [ -z $bootloader_fastboot ]
		then
			>& /dev/null 2>&1 fastboot $* reboot bootloader
			if [ $? -ne 0 ]; then
				echo "$errorp  Cannot reboot to bootloader."
			fi
	  fi
}

start()
{
	echo "------------------------------------ START ------------------------------------"
}

pause()
{
	echo "------------------------------------- END -------------------------------------"
	read -n1 -srp "Press any key to continue..."
	echo
}



# First place to start the execution
whoami | grep "root" >& /dev/null 2>&1
if [ $? -ne 0 ]
	then
		echo "You have not allowed to access this program."
		echo "Please run this script as root with one of type:"
		echo "  -  sudo ./`basename $0`"
		echo "  -  sudo bash `basename $0`"
		echo "  -  su -c ./`basename $0`"
		exit 1
	fi

echo "You will running to this program. If you are sure to modificate your device"
echo "press Y to allow and continue. Otherwise if deny and get out this program,"
echo "press N."
echo
while true
do
	read -n1 -p "Do you agree? [Y/N] " yn
	echo
	case $yn in
		[Yy]* )	break
				;;
		[Nn]* )	exit 1
				break
				;;
		* )		continue
				;;
	esac
done

errorp=ERROR:
cautionp=CAUTION:
infop=INFORMATION:
cd `dirname $0`

if [ -x $(command -v adb) ]
	then
		echo "Starting ADB service..."
		>& /dev/null 2>&1 adb start-server
	fi

# Main Menu Program
while true
do
	for v in adbfastboot_notfound no_connection error codename_false largest_anti not_mount twrp_exit root_exit; do
		unset $v
	done
	for v in recovery_adb recovery_fastboot reboot_recovery bootloader_adb bootloader_fastboot reboot_bootloader; do
		unset $v
	done
	for v in reboot_adb reboot_fastboot reboot_system; do
		unset $v
	done
	clear
	echo
	echo "MAIN MENU"
	echo "=========="
	echo
	echo "Current state:"
	adb devices 2>&1 | grep "device\>"
	if [ $? -ne 0 ]; then
		adb devices 2>&1 | grep "recovery\>"
		if [ $? -ne 0 ]; then
			fastboot devices 2>&1 | grep "fastboot\>"
			if [ $? -ne 0 ]; then
				echo "No connection. Please connect your device to PC."
			fi
		fi
	fi
	echo
	echo
	echo "   1.)  Check the bootloader status"
	echo "   2.)  Flash TWRP"
	echo "   3.)  Flash Lazyflasher (Disable DM-Verity and Force Encryption)"
	echo "   4.)  Flash Camera2 API Enabler"
	echo "   5.)  Flash Root"
	echo "   6.)  Install Manual Camera Compatibility Test APK"
	echo "   7.)  Reboot to system"
	echo "   8.)  Reboot to bootloader"
	echo "   9.)  Reboot to recovery"
	echo
	echo "   A.)  Install ADB and Fastboot programs"
	echo "   H.)  Show help and about this program"
	echo "   Q.)  Exit this program"
	echo
	read -p "Choose your option: " ahq123456789
	echo
	case $ahq123456789 in
		1 )		start
				check-adb
				if ! [ -z $adbfastboot_notfound ]; then
					pause
					continue
				fi
				check-fastboot
				if ! [ -z $no_connection ]; then
					pause
					continue
				fi
				check-codename
				if ! [ -z $codename_false ]; then
					pause
					continue
				fi
				check-unlock
				pause
				continue
				;;
		2 )		start
				check-adb
				if ! [ -z $adbfastboot_notfound ]; then
					pause
					continue
				fi
				check-fastboot
				if ! [ -z $no_connection ]; then
					pause
					continue
				fi
				check-codename
				if ! [ -z $codename_false ]; then
					pause
					continue
				fi
				check-antirollback
				if ! [ -z $largest_anti ]; then
					pause
					continue
				fi
				if ! [ -z $error ]; then
					pause
					continue
				fi
				flash-twrp
				if ! [ -z $twrp_exit ]; then continue; fi
				if ! [ -z $recoveryimg ]; then
					echo "Flashing recovery..."
					fastboot $* flash recovery $recoveryimg
					if [ $? -ne 0 ]; then echo "$errorp  Failed flash TWRP."
						else echo "$infop  Flash 'recovery' success."
					fi
				fi
				pause
				continue
				;;
		3 )		start
				check-adb
				if ! [ -z $adbfastboot_notfound ]; then
					pause
					continue
				fi
				check-sideload
				if ! [ -z $no_connection ]; then
					pause
					continue
				fi
				echo "Installing Lazyflasher..."
				>& /dev/null 2>&1 adb sideload ./data/lazyflasher.zip
				pause
				continue
				;;
		4 )		start
				check-adb
				if ! [ -z $adbfastboot_notfound ]; then
					pause
					continue
				fi
				check-sideload
				if ! [ -z $no_connection ]; then
					pause
					continue
				fi
				echo "Installing Camera2 API Enabler..."
				>& /dev/null 2>&1 adb sideload ./data/cam2api-enabler.zip
				sleep 5
				echo "Patching build.prop script..."
				mount-system
				if ! [ -z $not_mount ]; then
					pause
					continue
				fi
				write-prop
				unmount-system
				pause
				continue
				;;
		5 )		start
				check-adb
				if ! [ -z $adbfastboot_notfound ]; then
					pause
					continue
				fi
				flash-root
				if ! [ -z $no_connection ]; then
					pause
					continue
				fi
				if ! [ -z $root_exit ]; then continue; fi
				echo "Installing $rootsel"
				unset rootsel
				adb sideload $rootzip
				pause
				continue
				;;
		6 )		start
				check-adb
				if ! [ -z $adbfastboot_notfound ]; then
					pause
					continue
				fi
				check-devices1
				if ! [ -z $no_connection ]; then
					pause
					continue
				fi
				echo "Installing Manual Camera Compatibility Test APK..."
				adb install ./data/manualcamera.apk 2>&1 | grep "Success\>"
				if [ $? -ne 0 ]; then
					echo "$errorp  APK install failed."
				fi
				pause
				continue
				;;
		7 )		start
				check-adb
				if ! [ -z $adbfastboot_notfound ]; then
					pause
					continue
				fi
				reboot_system=1
				check-devices1
				if ! [ -z $no_connection ]; then
					check-devices2
					if ! [ -z $no_connection ]; then
						check-fastboot
						if ! [ -z $no_connection ]; then
							pause
							continue
						fi
					fi
				fi
				reboot-systemdevices
				pause
				continue
				;;
		8 )		start
				check-adb
				if ! [ -z $adbfastboot_notfound ]; then
					pause
					continue
				fi
				reboot_bootloader=1
				check-devices1
				if ! [ -z $no_connection ]; then
					check-devices2
					if ! [ -z $no_connection ]; then
						check-fastboot
						if ! [ -z $no_connection ]; then
							pause
							continue
						fi
					fi
				fi
				reboot-bootloader
				pause
				continue
				;;
		9 )		start
				check-adb
				if ! [ -z $adbfastboot_notfound ]; then
					pause
					continue
				fi
				reboot_recovery=1
				check-devices1
				if ! [ -z $no_connection ]; then
					check-devices2
					if ! [ -z $no_connection ]; then
						check-fastboot
						if ! [ -z $no_connection ]; then
							pause
							continue
						fi
					fi
				fi
				reboot-recovery
				pause
				continue
				;;

		[Aa]* )	echo "The installation require a network connection in computer."
				while true
				do
					read -n1 -p "Are you sure to continue install if you already connect to internet? [Y/N] " yn
					echo
					case $yn in
						[Yy]* )	break
								;;
						[Nn]* )	back=1
								break
								;;
						* )		continue
								;;
					esac
				done
				if ! [ -z $back ]; then
					unset back
					continue
				fi
				echo "Downloading and installing..."
				if [ -f /etc/debian_version ]; then
					apt-get install -f adb
					apt-get install -f fastboot
				elif [ -f /etc/SuSe-release ]; then
					zypper install -f adb
					zypper install -f fastboot
				elif [ -f /etc/redhat-release ]; then
					yum install -y adb
					yum install -y fastboot
				fi
				echo "Installation completed"
				read -n1 -srp "Press any key to continue..."
				echo
				continue
				;;
		[Hh]* )	clear
				echo "This program was written and created by Faizal Hamzah with the aim of making"
				echo "it easier for users to do the work of modifying Android mobile devices."
				echo
				echo "Facilities of this program, include:"
				echo "  1.  Check the status bootloader"
				echo "  2.  Flash TWRP"
				echo "  3.  Flash LazyFlasher"
				echo "  4.  Flash Camera2 API"
				echo "  5.  Flash Root Access"
				echo
				echo "This program is only for those who have a Xiaomi Redmi Note 5 Global/Pro"
				echo "phone (codename: Whyred)"
				echo
				read -n1 -srp "Press any key to continue..."
				clear
				echo "Special thanks:"
				echo "•  Google - Android"
				echo "•  TWRP team"
				echo "•  Orangefox team"
				echo "•  PitchBlack team"
				echo "•  Magisk team"
				echo "•  XDA"
				echo "•  Xiaomi Flashing Team"
				echo "•  and the users Xiaomi Redmi Note 5 Global/Pro"
				echo
				read -n1 -srp "Press any key to continue..."
				echo
				continue
				;;
		[Qq]* )	echo "Exiting from program..."
				if [ -x $(command -v adb) ]; then
					echo "Closing ADB service..."
					>& /dev/null 2>&1 adb kill-server
				fi
				read -n1 -srp "Press any key to continue..."
				echo
				clear
				exit 0
				break
				;;
		* )		continue
				;;
	esac
done

# end of program
