#!/usr/bin/env bash

# Whyred Console Toolkit for Linux
# ================================
#
#
# Created by:     Faizal Hamzah
#                 The Firefox Flasher
#                 The Firefox Foundation
# Created time:   June 14, 2020        10:34pm
# Modified time:  September 15, 2020   2:53am
#
#
# Description:
# This program was written and created by Faizal Hamzah with the aim of
# making it easier for users to do the work of modifying Android mobile
# devices. Facilities of this program, include:
#
#  1.  Check the status bootloader (e.g. Unlock and Lock)
#  2.  Flash custom recovery/TWRP
#  3.  Flash Disable DM-Verity and Force Encryption
#  4.  Flash Camera2 API Enabler
#  5.  Flash Root Access
#  6.  Run Terminal Android in PC
#  7.  Switch ADB Connection
#
# This program is only for those who have a Xiaomi Redmi Note 5
# Global/Pro phone (codename: Whyred)
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

######## FUNCTIONS STATE ########

# Shortcut functions
# Main menu will need the shortcut for their option
# This is will running any execution and put to shortut

######## CHECKING ADB AND FASTBOOT PROGRAMS ########
function check-adb ()
{
	print_console "Checking ADB and Fastboot programs..."
	if ! [ -x "$BASEDIR/bin/adb" ] || ! [ -x "$BASEDIR/bin/fastboot" ]; then
		print_console "$errorp  ADB and Fastboot not installed."
		adbfastboot_notfound=1
	fi
}

######## CHECKING DEVICES ON NORMAL STATE ########
function check-devices1 ()
{
	if [ -z $back ]; then
		print_console "Checking connection..."
	fi
	for var in no_connection back; do
		unset $var
	done
	if [ -z $SESSION_CON_ADB ]; then
		adb wait-for-device
	else
		sleep 0.1
	fi
	if ! (adb devices 2>&1 | grep "device\>"); then
		print_console "$errorp  Your device not connected. Check the driver or USB debugging."
		while true; do
			prompts "Try again? [Y/N] " yn
			case $yn in
				Y|y )	back=1
						print_console "Reconnecting..."
						check-devices1
						break
						;;
				N|n )	no_connection=1
						break
						;;
				* )		continue;;
			esac
		done
	else
		if ! [ -z $reboot_recovery ]; then
			recovery_adb=1
		elif ! [ -z $reboot_system ]; then
			reboot_adb=1
		elif ! [ -z $reboot_bootloader ]; then
			bootloader_adb=1
		fi
	fi
}

######## CHECKING DEVICES ON RECOVERY STATE ########
function check-devices2 ()
{
	if [ -z $back ]; then
		print_console "Checking connection..."
	fi
	for var in no_connection back; do
		unset $var
	done
	if [ -z $SESSION_CON_ADB ]; then
		adb wait-for-recovery
	else
		sleep 0.1
	fi
	if ! (adb devices 2>&1 | grep "recovery\>"); then
		print_console "$errorp  Your device not connected in recovery. Check the driver or reboot recovery again."
		while true; do
			prompts "Try again? [Y/N] " yn
			case $yn in
				Y|y )	back=1
						print_console "Reconnecting..."
						check-devices2
						break
						;;
				N|n )	no_connection=1
						break
						;;
				* )		continue;;
			esac
		done
	else
		if ! [ -z $reboot_recovery ]; then
			recovery_adb=1
		elif ! [ -z $reboot_system ]; then
			reboot_adb=1
		elif ! [ -z $reboot_bootloader ]; then
			bootloader_adb=1
		fi
	fi
}

######## CHECKING DEVICES ON NETWORK STATE ########
######## SWITCHING ADB USB TO ADB NETWORK ########
function switch-adb ()
{
	unset no_connection
	if [ -z $ippadrs ]; then
		print_console "Identifying IP Address from your device..."
	fi
	ipaddrs=$(adb shell ip addr | grep "wlan0" | grep inet | cut -f 2)
	ipaddrs=$(echo $ipaddrs | cut -f 1 -d '/') && ipaddrs=$(echo $ipaddrs | cut -f 2 -d ' ')
	tcport=5555
	if (adb devices 2>&1 | grep "$ipaddrs:$tcport" >& /dev/null); then
		while true; do
			print_console "$infop  Your device already connected on network."
			prompts "Do you want to disable ADB network? [Y/N] " yn
			case $yn in
				Y|y )	back=1
						print_console "Disconnecting ADB from network..."
						adb disconnect >& /dev/null
						print_console "Please plug USB cable on this PC and your device."
						pause
						print_console "Connecting..."
						adb wait-for-device
						if ! (adb usb 2>&1); then
							print_console "$errorp  Connected failure. Please try again."
							print_console "$endp"; pause
						else
							print_console "Successfully connected to USB."
							for var in tcport ipaddrs; do unset $var; done
							print_console "$endp"; pause
						fi
						break
						;;
				N|n )	back=1
						break
						;;
				* )		continue;;
			esac
		done
	else
		print_console "Disconnecting ADB from USB..."
		adb disconnect >& /dev/null
		adb tcpip $tcport
		print_console "Please unplug USB cable on this PC and your device."
		pause
		print_console "Connecting to your IP Address and ADB Server Port..."
		adb connect $ipaddrs:$tcport
		if ! (adb devices 2>&1 | grep "$ipaddrs:$tcport"); then
			print_console "$errorp  Connected failure. Plug your device and try again."
			adb wait-for-device
			adb usb 2>&1
		else
			print_console "$infop  Success connected. To back the USB, disable network at your device."
		fi
	fi
}

######## CHECKING DEVICES ON BOOTLOADER STATE ########
function check-fastboot ()
{
	unset no_connection
	print_console "Checking fastboot connection..."
	if ! (fastboot devices 2>&1 | grep "fastboot\>"); then
		print_console "$errorp  Your device not connected."
		no_connection=1
	else
		if ! [ -z $reboot_recovery ]; then
			recovery_fastboot=1
		elif ! [ -z $reboot_system ]; then
			reboot_fastboot=1
		elif ! [ -z $reboot_bootloader ]; then
			bootloader_fastboot=1
		fi
	fi
}

######## CHECKING DEVICES CODENAME ########
function check-codename ()
{
	print_console "Checking require codename devices..."
	if ! (fastboot getvar product 2>&1 | grep "^product: *whyred$"); then
		print_console "$errorp  Your device is not Xiaomi Redmi Note 5/Pro. The code must 'whyred'."
		codename_false=1
	fi
}

######## CHECKING BOOTLOADER STATUS AND MAY GIVE 2 OPTIONS ########
######## 1.  UNLOCK BOOTLOADER
######## 2.  LOCK BOOTLOADER
function check-unlock ()
{
	print_console "Checking the device bootloader..."
	CURRENT_RESULT=true
	result=$(fastboot oem device-info 2>&1 | grep "Device unlocked:" | cut -f 4 -d ' ')
	if [ -z $result ]; then
		result=false
	fi
	if [ "$result" != "$CURRENT_RESULT" ]; then
		while true; do
			if ($dialog						\
				--title "Unlock bootloader"	\
				--yesno						\
"$infop  Your device locked bootloader.
This script will be unlock using Mi Unlock Tool. For unlock bootloader:
  •  You must have a Mi Account.
  •  Activate OEM unlock, USB debugging and request the Mi Account
     permission to be authorized in developer options > Mi Unlock
     Status.
	 
If not yet do it, follow this instruction and run this again.
Are you ready?" 17 75						\
				3>&1 1>&2 2>&3); then
				if ! [ -x "$(command -v java)" ]; then
					$dialog --msgbox "Mi Unlock Tool requires OpenJDK. So install it first before unlocking bootloader." 8 48
					break
				else
					JAVACMD="$(command -v java)"
				fi
				if ! [ -f "$BASEDIR/bin/Mi-Unlock-Tool.jar" ]; then
					curl -o "$BASEDIR/tmp/Mi-Unlock-Tool.zip" http://us1.fastandroid.download/tool/MiUnlock-Linux-Mac.zip
					unzip -o "$BASEDIR/tmp/Mi-Unlock-Tool.zip" MiUnlockTool/bin/MiUnlockTool.jar -d "$BASEDIR/tmp/"
					mv "$BASEDIR/tmp/MiUnlockTool/bin/MiUnlockTool.jar" "$BASEDIR/bin/Mi-Unlock-Tool.jar"
					rm -rf "$BASEDIR/tmp/MiUnlockTool"
					rm -f "$BASEDIR/tmp/Mi-Unlock-Tool.zip"
				fi
				while true; do
					if (mi_username=$($dialog															\
									  --title "Unlock bootloader"										\
									  --inputbox "\n Type your Mi Account username/email/phone:" 10 52	\
									  3>&1 1>&2 2>&3)); then
						if [ "$mi_username" == "" ]; then
							continue
						fi
						break
					else
						break
					fi
				done
				while true; do
					if (mi_password=$($dialog													\
									  --title "Unlock bootloader"								\
									  --passwordbox "\n Type your Mi Account password:" 10 52	\
									  3>&1 1>&2 2>&3)); then
						if [ "$mi_password" == "" ]; then
							continue
						fi
						break
					else
						break
					fi
				done
				while true; do
					if ($dialog																		\
						--title "Unlock bootloader"													\
						--yesno "Unlocking bootloader that will erase all data. Do you agree?" 9 45	\
						3>&1 1>&2 2>&3); then
						"$JAVACMD" -jar "$BASEDIR/bin/Mi-Unlock-Tool.jar" $mi_username $mi_password
						break
					else
						break
					fi
				done
				break
			else
				break
			fi
		done
	elif [ "$result" == "$CURRENT_RESULT" ]; then
		while true; do
			if ($dialog						\
				--title "Lock bootloader"	\
				--yesno						\
"$infop  Your device already unlocked bootloader.
Do you want to lock bootloader?" 8 51		\
				3>&1 1>&2 2>&3); then
				if ! (fastboot oem lock 2>&1); then
					print_console "$errorp  Failed locked."
				fi
				break
			else
				break
			fi
		done
	fi
}

######## CHECKING ANTI-ROLLBACK SYSTEM ########
function check-antirollback ()
{
	print_console "Checking device antirollback version..."
	CURRENT_ANTI_VER=4
	arbver=$(fastboot getvar anti 2>&1 | grep anti: | cut -f 2 -d ' ')
	if [ -z $arbver ]; then
		arbver=0
	fi
	if [ $arbver -gt $CURRENT_ANTI_VER ]; then
		print_console "$errorp  Current device antirollback version is greater than this package."
		largest_anti=1
	elif [ $arbver -eq $CURRENT_ANTI_VER ]; then
		if ! fastboot flash antirbpass "$BASEDIR/recovery/dummy.img"; then
			print_console "$errorp  Failed flash 'antirbpass'."
		else
			print_console "$infop  Flash 'antirbpass' success."
		fi
	fi
}

######## FLASH TWRP MENU AND FLASH IT ########
function flash-twrp ()
{
	while true; do
		choice=$($dialog												\
				 --title "Flash TWRP"									\
				 --menu "\n Choose TWRP you want to flash"	13 53 4		\
					1 " Team Win Recovery Project"						\
					2 " Orange Fox Recovery"							\
					3 " PitchBlack Recovery Project"					\
					4 " Let me choose"									\
				 --ok-button "ENTER to next"							\
				 --cancel-button "ESC to back"							\
				 3>&1 1>&2 2>&3)
		
		case $choice in
			1 )	if ! [ -f "$BASEDIR/recovery/twrp.img" ]; then
					curl -o "$BASEDIR/recovery/twrp.img" \
						 --referer 'https://dl.twrp.me/whyred/twrp-3.4.0-0-whyred.img' \
						 -k https://dl.twrp.me/whyred/twrp-3.4.0-0-whyred.img
				fi
				recoveryimg="$BASEDIR/recovery/twrp.img"
				break
				;;
			2 )	if ! [ -f "$BASEDIR/recovery/ofox.img" ]; then
					curl -o "$BASEDIR/tmp/ofox.zip" \
							 https://files.orangefox.download/OrangeFox-Beta/whyred/OrangeFox-R11.0_1-Beta-whyred.zip
					unzip -o "$BASEDIR/tmp/ofox.zip" recovery.img -d "$BASEDIR/recovery/"
					mv "$BASEDIR/recovery/recovery.img" "$BASEDIR/recovery/ofox.img"
					rm -f "$BASEDIR/tmp/ofox.zip"
				fi
				recoveryimg="$BASEDIR/recovery/ofox.img"
				break
				;;
			3 )	if ! [ -f "$BASEDIR/recovery/pbrp.img" ]; then
					curl -o "$BASEDIR/tmp/pbrp.zip" \
							 https://udomain.dl.sourceforge.net/project/pbrp/whyred/PBRP-whyred-3.0.0-20200801-1730-OFFICIAL.zip
					unzip -o "$BASEDIR/tmp/pbrp.zip" TWRP/recovery.img -d "$BASEDIR/recovery/"
					mv "$BASEDIR/recovery/TWRP/recovery.img" "$BASEDIR/recovery/pbrp.img"
					rm -rf "$BASEDIR/recovery/TWRP"
					rm -f "$BASEDIR/tmp/pbrp.zip"
				fi
				recoveryimg="$BASEDIR/recovery/pbrp.img"
				break
				;;
			4 )	while true; do
					if (recoveryimg=$($dialog													\
									  --title "Flash TWRP"										\
									  --inputbox "\n Type an img file (with directory): " 9 51	\
									  3>&1 1>&2 2>&3)); then
						while true; do
							if ! [ -f "$recoveryimg" ]; then
								if (recoveryimg=$($dialog																			\
												  --title "Flash TWRP"																\
												  --inputbox "\n Image file not found.\n Type an img file (with directory): " 10 51	\
												  3>&1 1>&2 2>&3)); then
									continue
								else
									twrp_exit=1
								fi
								break
							fi
							if ! [ -z $twrp_exit ]; then
								flash_twrp
								break
							fi
							break
						done
					else
						twrp_exit=1
					fi
					break
				done
				;;
			* )	twrp_exit=1
				break
				;;
		esac
		if ! [ -z $twrp_exit ]; then
			flash_twrp
			break
		fi
	done
}

######## CHECKING DEVICES ON SIDELOAD STATE ########
######## IF YOU WANNA FLASH BY ADB SIDELOAD
function check-sideload () {
	if [ -z $back ]; then
		unset no_connection
		print_console "$cautionp  Select ADB Sideload on Recovery menu > Advanced, then swipe and automatically flash."
	fi
	unset back
	adb wait-for-sideload
	if ! (adb devices 2>&1 | grep "sideload\>"); then
		print_console "$errorp  Your device not connected in sideload. Check the driver or reboot recovery again."
		while true; do
			prompts "Try again? [Y/N] " yn
			case $yn in
				Y|y )	back=1
						print_console "Reconnecting..."
						check-sideload
						break
						;;
				N|n )	no_connection=1
						break
						;;
				* )		continue;;
			esac
		done
	fi
}

######## CAMERA2 API ENABLER MENU ########

######## MOUNTING /system ########
function mount-system ()
{
	if [ -z $back ]; then
		MOUNT_SCRIPT="mount-system.sh"
		UNMOUNT_SCRIPT="unmount-system.sh"
		print_console "Mounting system..."
		>& /dev/null 2>&1 adb push "$BASEDIR/data/$MOUNT_SCRIPT" /tmp/
		>& /dev/null 2>&1 adb push "$BASEDIR/data/$UNMOUNT_SCRIPT" /tmp/
		>& /dev/null 2>&1 adb shell "chmod u+rwx,g+rx,g-w,o+rx,o-w /tmp/$MOUNT_SCRIPT"
		>& /dev/null 2>&1 adb shell "chmod u+rwx,g+rx,g-w,o+rx,o-w /tmp/$UNMOUNT_SCRIPT"
	fi
	unset back
	>& /dev/null 2>&1 adb shell "/sbin/sh /tmp/$MOUNT_SCRIPT"
	for SYSTEM_MOUNT in '/system' '/system/system' '/system_root' '/system_root/system'; do
		>& /dev/null 2>&1 adb pull $SYSTEM_MOUNT/build.prop "$BASEDIR/tmp/"
	done
	if ! [ -f "$BASEDIR/tmp/build.prop" ]; then
		print_console "$errorp  /system not yet mounted."
		while true; do
			prompts "Try again? [Y/N] " yn
			case $yn in
				Y|y )	back=1
						mount-system
						break
						;;
				N|n )	not_mount=1
						break
						;;
				* )		continue;;
			esac
		done
	else
		rm -f "$BASEDIR/tmp/build.prop"
	fi
}

######## ACTIVATE CAMERA2 API SCRIPT ON ADDON AND BUILD.PROP ########
function write-prop ()
{
	adb push "$BASEDIR/data/patch.sh" /tmp/
	adb shell "chmod u+rwx,g+rx,g-w,o+rx,o-w /tmp/patch.sh"
	adb shell "/sbin/sh /tmp/patch.sh"
}

######## UNMOUNTING /system ########
function unmount-system ()
{
	print_console "Unmounting system..."
	>& /dev/null 2>&1 adb shell "/sbin/sh /tmp/$UNMOUNT_SCRIPT"
	>& /dev/null 2>&1 adb shell "rm -rf /tmp/*"
}

######## FLASH ROOT MENU AND FLASH IT ########
function flash-root ()
{
	while true; do
		choice=$($dialog												\
				 --title "Install Root"									\
				 --menu "\n Choose Root app you want to install:" 12 53	\
				 3														\
					1 " SuperSU"										\
					2 " Magisk"											\
					3 " Let me choose"									\
				 --ok-button "ENTER to next"							\
				 --cancel-button "ESC to back"							\
				 3>&1 1>&2 2>&3)
		
		case $choice in
			1 )	if ! [ -f "$BASEDIR/data/supersu.zip" ]; then
					curl -o "$BASEDIR/data/supersu.zip" http://supersuroot.org/downloads/SuperSU-v2.82-201705271822.zip
				fi
				rootsel=SuperSU
				rootzip="$BASEDIR/data/supersu.zip"
				;;
			2 )	if ! [ -f "$BASEDIR/data/magisk.zip" ]; then
					curl -o "$BASEDIR/data/magisk.zip" https://github.com/topjohnwu/Magisk/releases/download/v20.4/Magisk-v20.4.zip
				fi
				rootsel=Magisk
				rootzip="$BASEDIR/data/magisk.zip"
				;;
			3 )	while true; do
					if (rootzip=$($dialog													\
								  --title "Install Root"									\
								  --inputbox "\n Type a zip file (with directory): " 9 51	\
								  3>&1 1>&2 2>&3)); then
						while true; do
							if ! [ -f "$rootzip" ]; then
								if (rootzip=$($dialog																			\
											  --title "Install Root"															\
											  --inputbox "\n Zip file not found.\n Type a zip file (with directory): " 10 51	\
											  3>&1 1>&2 2>&3)); then
									continue
								else
									root_exit=1
								fi
								break
							fi
							if ! [ -z $root_exit ]; then
								flash_root
								break
							fi
							break
						done
					else
						root_exit=1
					fi
					break
				done
				rootsel="custom root"
				;;
			* )	root_exit=1
				clear
				break
				;;
		esac
		if ! [ -z $root_exit ]; then
			flash-root
			break
		fi
		check-sideload
		case $choice in
			1 )	break;;
			2 )	break;;
		esac
	done
}

######## REBOOT OPTIONS ########
######## TO RECOVERY
function reboot-recovery ()
{
	if ! [ -z $recovery_adb ]; then
		print_console "Rebooting to recovery..."
		DO_REBOOT_RECOVERY="adb reboot recovery"
	elif ! [ -z $recovery_fastboot ]; then
		if [ -z $recoveryimg ]; then
			print_console "Booting to custom recovery..."
			recoveryimg="$BASEDIR/recovery/twrp.img"
		else
			print_console "Rebooting to recovery..."
		fi
		DO_REBOOT_RECOVERY="fastboot boot \"$recoveryimg\""
	fi
	if ! ($DO_REBOOT_RECOVERY); then
		print_console "$errorp  Cannot boot to recovery."
	elif ($DO_REBOOT_RECOVERY); then
		if ! [ -z $recovery_fastboot ]; then
			print_console "$infop  Download 'recovery' to 'boot' success."
		fi
	fi
	unset DO_REBOOT_RECOVERY
}

######## TO NORMAL BOOT
function reboot-systemdevices ()
{
	print_console "Rebooting..."
	if ! [ -z $reboot_adb ]; then
		DO_REBOOT_SYSTEM="adb reboot"
	elif ! [ -z $reboot_fastboot ]; then
		DO_REBOOT_SYSTEM="fastboot reboot"
	fi
	if ! (>& /dev/null 2>&1 $DO_REBOOT_SYSTEM); then
		print_console "$errorp  Cannot reboot."
	fi
	unset DO_REBOOT_SYSTEM
}

######## TO BOOTLOADER
function reboot-bootloader ()
{
	print_console "Rebooting to bootloader..."
	if ! [ -z $bootloader_adb ]; then
		DO_REBOOT_BOOTLOADER="adb reboot bootloader"
	elif ! [ -z $bootloader_fastboot ]; then
		DO_REBOOT_BOOTLOADER="fastboot reboot bootloader"
	fi
	if ! (>& /dev/null 2>&1 $DO_REBOOT_BOOTLOADER); then
		print_console "$errorp  Cannot reboot to bootloader."
	fi
	unset DO_REBOOT_BOOTLOADER
}

function pause ()
{
	read -n1 -srp "Press any key to continue..."
	echo
}

function prompts ()
{
	read -n1 -p "$1" $2
	echo
}

function print_console ()
{
	echo -e "$1"
}



######## START SCRIPT ########
# First place to start the execution
BASEFILE=$(basename "$0")
BASEDIR=$(dirname "$0")
PATH="$BASEDIR/bin:$PATH"
errorp="ERROR:"
cautionp="CAUTION:"
infop="INFORMATION:"
startp="------------------------------------ START ------------------------------------"
endp="------------------------------------- END -------------------------------------"
maintitle="Whyred Console Toolkit - Version 1.1"
dialog=whiptail
if ! [ -x "$(which "$dialog")" ]; then
	dialog=dialog
fi

if ! (whoami | grep "root" >& /dev/null 2>&1); then
	print_console "You have not allowed to access this program.\nPlease run this script as root with one of type:"
	for STRINGS_TEXT in '  •  sudo ./' '  •  sudo bash ' '  •  su -c ./'; do
		print_console "$STRINGS_TEXT$BASEFILE"
	done
	exit 1
fi

for STRINGS_TEXT in \
	'You will running to this program. If you are sure to modificate your device'\
	'press Y to allow and continue. Otherwise if deny and get out this program,'\
	'press N. \n'
do
	print_console "$STRINGS_TEXT"
done
while true; do
	prompts "Do you agree? [Y/N] " yn
	case $yn in
		Y|y )	break;;
		N|n )	exit 1
				break
				;;
		* )		continue;;
	esac
done

cd $BASEDIR
if [ -x "$BASEDIR/bin/adb" ]; then
	print_console "ADB installed on Console Toolkit."
	print_console "Starting ADB service..."
	adb start-server
	echo
fi

######## MAIN MENU ########
# Main Menu Program
# print_console '\e[0;97;44m'
while true; do
	for VAR_SET in \
		'adbfastboot_notfound' back 'no_connection' error 'codename_false' largest_anti			\
		'not_mount' twrp_exit 'SESSION_CON_ADB' root_exit 'recovery_adb' recovery_fastboot		\
		'reboot_recovery' bootloader_adb 'bootloader_fastboot' reboot_bootloader				\
		'reboot_adb' reboot_fastboot 'reboot_system' MOUNT_SCRIPT 'UNMOUNT_SCRIPT' current_states
	do
		unset $VAR_SET
	done

	serialno_ip="$(adb devices | grep "device\>" | cut -f 1)"
	current_states="$serialno_ip    device"
	if [ "$current_states" == "    device" ]; then
		serialno_ip="$(adb devices | grep "recovery\>" | cut -f 1)"
		current_states="$serialno_ip    recovery"
		if [ "$current_states" == "    recovery" ]; then
			serialno_ip="$(fastboot devices | grep "fastboot\>" | cut -f 1)"
			current_states="$serialno_ip    fastboot"
			if [ "$current_states" == "    fastboot" ]; then
				current_states="Nothing device connection. Plug your device to PC with USB cable."
			fi
		fi
	fi
	unset serialno_ip
	
	choice=$($dialog																	\
			 --backtitle "$maintitle"													\
			 --title "Main Menu"														\
			 --menu "\n Current state:\n $current_states\n Choose your option:"	23 73 	\
			 12																			\
				1 " Check the bootloader status" 										\
				2 " Flash TWRP (Custom recovery)"			 							\
				3 " Flash Disable DM-Verity and Force Encryption"						\
				4 " Flash Camera2 API Enabler"											\
				5 " Flash Root"															\
				6 " Emulate the device shell"											\
				7 " Reboot to system"													\
				8 " Reboot to bootloader"												\
				9 " Reboot to recovery"													\
				10 " Switch ADB Connection"												\
				11 " Other"																\
				12 " Exit the program"													\
			 --ok-button "ENTER to next"												\
			 --cancel-button "ESC to refresh"											\
			 3>&1 1>&2 2>&3)

	clear
	case $choice in
		1 )		print_console "$startp"
				check-adb; if ! [ -z $adbfastboot_notfound ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				check-fastboot; if ! [ -z $no_connection ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				check-codename; if ! [ -z $codename_false ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				check-unlock
				print_console "$endp"; pause
				clear
				continue
				;;
		2 )		print_console "$startp"
				check-adb; if ! [ -z $adbfastboot_notfound ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				check-fastboot; if ! [ -z $no_connection ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				check-codename; if ! [ -z $codename_false ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				check-antirollback
				if ! [ -z $largest_anti ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				if ! [ -z $error ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				flash-twrp
				if ! [ -z $twrp_exit ]; then
					clear
					continue
				fi
				print_console "Flashing recovery..."
				if ! [ -z $recoveryimg ]; then
					if ! (fastboot flash recovery "$recoveryimg"); then
						print_console "$errorp  Failed flash TWRP."
					else
						print_console "$infop  Flash 'recovery' success."
					fi
				fi
				print_console "$endp"; pause
				clear
				continue
				;;
		3 )		print_console "$startp"
				check-adb; if ! [ -z $adbfastboot_notfound ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				check-sideload; if ! [ -z $no_connection ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				print_console "Installing Lazyflasher..."
				if ! [ -f "$BASEDIR/data/lazyflasher.zip" ]; then
					curl -o "$BASEDIR/data/lazyflasher.zip" https://zackptg5.com/downloads/Disable_Dm-Verity_ForceEncrypt_03.04.2020.zip
				fi
				adb sideload "$BASEDIR/data/lazyflasher.zip"
				print_console "$endp"; pause
				clear
				continue
				;;
		4 )		print_console "$startp"
				check-adb; if ! [ -z $adbfastboot_notfound ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				check-sideload; if ! [ -z $no_connection ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				print_console "Installing Camera2 API Enabler..."
				adb sideload "$BASEDIR/data/cam2api-enabler.zip"
				sleep 5
				print_console "Patching build.prop script..."
				mount-system; if ! [ -z $not_mount ]; then
					unmount-system
					print_console "$endp"; pause
					clear
					continue
				fi
				write-prop
				unmount-system
				print_console "$endp"; pause
				clear
				continue
				;;
		5 )		print_console "$startp"
				check-adb; if ! [ -z $adbfastboot_notfound ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				flash-root; if ! [ -z $no_connection ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				if ! [ -z $root_exit ]; then
					clear
					continue
				fi
				print_console "Installing $rootsel..."
				unset rootsel
				adb sideload "$rootzip"
				print_console "$endp"; pause
				clear
				continue
				;;
		6 )		print_console "$startp"
				check-adb; if ! [ -z $adbfastboot_notfound ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				SESSION_CON_ADB=1
				print_console "Trying connect to normal state..."
				check-devices1
				if ! [ -z $no_connection ]; then
				print_console "Trying connect to recovery state..."
				check-devices2
				if ! [ -z $no_connection ]; then
					print_console "$endp"; pause
					clear
					continue
				fi; fi
				print_console "To terminate from shell, type 'exit'..."
				adb shell
				print_console "$endp"; pause
				clear
				continue
				;;
		7 )		print_console "$startp"
				check-adb; if ! [ -z $adbfastboot_notfound ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				SESSION_CON_ADB=1
				reboot_system=1
				print_console "Trying reboot from normal state..."
				check-devices1
				if ! [ -z $no_connection ]; then
				print_console "Trying reboot from recovery state..."
				check-devices2
				if ! [ -z $no_connection ]; then
				print_console "Trying reboot from fastboot state..."
				check-fastboot
				if ! [ -z $no_connection ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				fi; fi
				reboot-systemdevices
				print_console "$endp"; pause
				clear
				continue
				;;
		8 )		print_console "$startp"
				check-adb; if ! [ -z $adbfastboot_notfound ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				SESSION_CON_ADB=1
				reboot_bootloader=1
				print_console "Trying reboot from normal state..."
				check-devices1
				if ! [ -z $no_connection ]; then
				print_console "Trying reboot from recovery state..."
				check-devices2
				if ! [ -z $no_connection ]; then
				print_console "Trying reboot from fastboot state..."
				check-fastboot
				if ! [ -z $no_connection ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				fi; fi
				reboot-bootloader
				print_console "$endp"; pause
				clear
				continue
				;;
		9 )		print_console "$startp"
				check-adb; if ! [ -z $adbfastboot_notfound ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				SESSION_CON_ADB=1
				reboot_recovery=1
				print_console "Trying reboot from normal state..."
				check-devices1
				if ! [ -z $no_connection ]; then
				print_console "Trying reboot from recovery state..."
				check-devices2
				if ! [ -z $no_connection ]; then
				print_console "Trying reboot from fastboot state..."
				check-fastboot
				if ! [ -z $no_connection ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				fi; fi
				reboot-recovery
				print_console "$endp"; pause
				clear
				continue
				;;
		10 )	print_console "$startp"
				check-adb; if ! [ -z $adbfastboot_notfound ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				check-devices1; if ! [ -z $no_connection ]; then
					print_console "$endp"; pause
					clear
					continue
				fi
				switch-adb; if ! [ -z $back ]; then
					clear
					continue
				fi
				print_console "$endp"; pause
				clear
				continue
				;;
		11 )	while true; do
					choice=$($dialog												\
							 --backtitle "$maintitle"								\
							 --title "Other"										\
							 --menu "\n Choose your option:" 12 53					\
							 3														\
								1 " Install OpenJDK program"						\
								2 " Install ADB and Fastboot programs"				\
								3 " Show help and about this program"				\
							 --ok-button "ENTER to next"							\
							 --cancel-button "ESC to back"							\
							 3>&1 1>&2 2>&3)

					case $choice in
						1 )	if ! [ -x $(command -v java) ]; then
								while true; do
									if ($dialog --yesno "The installation require a network connection in PC. Do you want to continue install?" 9 51 3>&1 1>&2 2>&3); then
										break
									else
										back=1
										break
									fi
								done
								if ! [ -z $back ]; then
									unset back
									continue
								fi
								print_console "Downloading and installing..."
								{
									i=0
									echo $i
      								i=$(expr $i + 1)
									print_console "OpenJDK (Java Runtime Environment)"
									echo 5
									>& /dev/null 2>&1 echo y | apt-get install openjdk-8-jre || error=1
									>& /dev/null 2>&1 echo y | yum install java-1.8.0-openjdk || error=1
									>& /dev/null 2>&1 echo y | pacman -S jre-openjdk-headless jre-openjdk jdk-openjdk openjdk-doc openjdk-src || error=1
									echo 100
								} | $dialog --gauge "Downloading and installing..." 6 39 0
								if [ $error -ne 1 ]; then
									$dialog --msgbox "$infop  OpenJDK successfully installed." 7 49
								else
									$dialog --msgbox "$errorp  Failed installed. Please try again." 7 47
								fi
							else
								$dialog --msgbox "$infop  OpenJDK already installed." 7 44
							fi
							continue
							;;
						2 )	if ! [ -f "$BASEDIR/bin/adb" ] || ! [ -f "$BASEDIR/bin/fastboot" ]; then
								while true; do
									if ($dialog --yesno "The installation require a network connection in PC. Do you want to continue install?" 9 51 3>&1 1>&2 2>&3); then
										break
									else
										back=1
										break
									fi
								done
								if ! [ -z $back ]; then
									unset back
									continue
								fi
								print_console "Downloading and installing..."
								{
									i=0
									echo $i
      								i=$(expr $i + 1)
									print_console "Android Platform Tools (include ADB and Fastboot)"
									echo 1
									if ! [ -x $(command -v curl) ]; then
										echo 18
										>& /dev/null 2>&1 echo y | apt-get install curl || error=1
										>& /dev/null 2>&1 echo y | yum install curl || error=1
										>& /dev/null 2>&1 echo y | pacman -S curl || error=1
										echo 20
									elif [ -x $(command -v curl) ]; then
										echo 23
										if ! [ -f "$BASEDIR/bin/pkg/android-platform-tools-linux.zip" ]; then
											echo 24
											>& /dev/null 2>&1 curl -o "$BASEDIR/bin/pkg/android-platform-tools-linux.zip" https://dl.google.com/android/repository/platform-tools_r30.0.4-linux.zip?hl=id
											echo 37
						    			fi
										if [ -f "$BASEDIR/bin/pkg/android-platform-tools-linux.zip" ]; then
											if ! [ -x $(command -v unzip) ]; then
												echo 38
												>& /dev/null 2>&1 echo y | apt-get install zip || error=1
												>& /dev/null 2>&1 echo y | yum install zip || error=1
												>& /dev/null 2>&1 echo y | pacman -S zip || error=1
												echo 40
											fi
											echo 41
											>& /dev/null 2>&1 rm -rf "$BASEDIR/bin/platform-tools/"
											>& /dev/null 2>&1 unzip -o "$BASEDIR/bin/pkg/android-platform-tools-linux.zip" -d "$BASEDIR/bin/"
											echo 72
											cd "$BASEDIR/bin"
											ln -s platform-tools/adb adb
											ln -s platform-tools/fastboot fastboot
											echo 77
											ln -s platform-tools/dmtracedump dmtracedump
											echo 80
											ln -s platform-tools/e2fsdroid e2fsdroid
											echo 82
											ln -s platform-tools/hprof-conv hprof-conv
											echo 83
											ln -s platform-tools/make_f2fs make_f2fs
											echo 86
											ln -s platform-tools/mke2fs mke2fs
											echo 87
											ln -s platform-tools/mke2fs.conf mke2fs.conf
											echo 90
											ln -s platform-tools/sload_f2fs sload_f2fs
											echo 94
											ln -s platform-tools/sqlite3 sqlite3
											cd ..
											if ! [ -f "$BASEDIR/bin/adb" ] || ! [ -f "$BASEDIR/bin/fastboot" ]; then
												error=1
											fi
										fi
										echo 100
									fi
								} | $dialog --gauge "Downloading and installing..." 6 39 0
								if [ "$error" != "1" ]; then
									$dialog --msgbox "$infop  ADB and Fastboot successfully installed." 7 58
								else
									$dialog --msgbox "$errorp  Failed installed. Please try again." 7 47
								fi
							else
								$dialog --msgbox "$infop  ADB and Fastboot already installed." 7 54
							fi
							continue
							;;
						3 )	$dialog								\
							--title "About"						\
							--msgbox							\
"This program was written and created by Faizal Hamzah with the aim of
making it easier for users to do the work of modifying Android mobile
devices. Facilities of this program, include:

  1.  Check the status bootloader (e.g. Unlock and Lock)
  2.  Flash custom recovery/TWRP
  3.  Flash Disable DM-Verity and Force Encryption
  4.  Flash Camera2 API Enabler
  5.  Flash Root Access
  6.  Run Terminal Android in PC
  7.  Switch ADB Connection

This program is only for those who have a Xiaomi Redmi Note 5
Global/Pro phone (codename: Whyred)

Special thanks:
  •   Google — Android
  •   TWRP team
  •   Orangefox team
  •   PitchBlack team
  •   Magisk team
  •   XDA
  •   Xiaomi Flashing Team
  •   and the users Xiaomi Redmi Note 5 Global/Pro
  
Contact person:
  •   https://api.whatsapp.com/send?phone=6288228419117
  •   https://www.facebook.com/thefirefoxflasher
  •   https://www.instagram.com/thefirefoxflasher_" 27 74		\
							--scrolltext						\
							--ok-button "ESC to OK"				\
							continue
							;;
						* )	clear
							break
							;;
					esac
				done
				continue
				;;
		12 )	print_console "Exiting from program..."
				if [ -x $(command -v adb) ]; then
					print_console "Closing ADB service..."
					>& /dev/null 2>&1 adb kill-server
				fi
				pause
				# print_console '\e[0m'
				exit 0
				break
				;;
		* )		clear
				continue
				;;
	esac
done

######## END OF SCRIPT ########
# end of program
