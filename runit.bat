@ECHO OFF
:STARTSCRIPT
::
:: Microsoft Windows(R) Command Script
:: Copyright (c) 1990-2020 Microsoft Corp. All rights reserved.
::

::
:: DETAILS
::

::
:: runit.bat
:: Whyred Console Toolkit for Windows
::
:: Date/Time Created:          06/14/2020  10:34pm
:: Date/Time Modified:         09/02/2020  4:52pm
:: Operating System Created:   Windows 10 Pro
::
:: This script created by:
::   Faizal Hamzah
::   The Firefox Foundation
::
::
:: VersionInfo:
::
::    File version:      1,1
::    Product Version:   1,1
::
::    CompanyName:       The Firefox Flasher
::    FileDescription:   Make it easier to modified the Xiaomi Redmi Note 5 Global/Pro device.
::    FileVersion:       1.1
::    InternalName:      runit
::    LegalCopyright:    The Firefox Foundation
::    OriginalFileName:  runit.sh
::    ProductName:       Whyred Console Toolkit
::    ProductVersion:    1.1
::



:: BEGIN

:1
if "%OS%" == "Windows_NT" goto 2

ver | find "Operating System/2" >nul
if not errorlevel 1 goto winos2

ver | find "OS/2" >nul
if not errorlevel 1 goto winos2

ver | find "Windows 95" >nul
if not errorlevel 1 goto winos2

ver | find "Windows 98" >nul
if not errorlevel 1 goto winos2

ver | find "Chicago" >nul
if not errorlevel 1 goto winos2

ver | find "Nashville" >nul
if not errorlevel 1 goto winos2

ver | find "Memphis" >nul
if not errorlevel 1 goto winos2

ver | find "Millennium" >nul
if not errorlevel 1 goto winos2

ver | find "[Version 4" >nul
if not errorlevel 1 goto winos2

goto dos


:2
setlocal
for %%v in (OS/2 NT Hydra Cairo Neptune Whistler 2000 XP) do (
	ver | findstr /r /c:"%%v" >nul
	if not errorlevel 1 goto nt
)

for /f "tokens=5,6 delims=[.XP " %%v in ('ver') do ( set "version=%%v.%%w" )
for %%v in (5.00 5.1 5.2 5.3) do ( if "%version%" == "%%v" goto nt )
for /f "tokens=4,5 delims=[.XP " %%v in ('ver') do ( set "version=%%v.%%w" )
for %%v in (5.1 5.2 5.3 6.0) do ( if "%version%" == "%%v" goto nt )

>nul 2>&1 cacls %systemroot%\system32\config\system
if [%errorlevel%] NEQ [0] (
	echo You have not allowed to access this program.
	echo Please run this script as administrator user mode or with an
	echo administrative privileges access.
	echo.
	echo Access is denied.
	endlocal
	exit /b
	goto endscript
)

echo You will running to this program. If you are sure to modificate your device
echo press Y to allow and continue. Otherwise if deny and get out this program,
echo press N.
echo.
choice /c yn /n /m "Do you agree? [Y/N] "
if errorlevel 2 (
	endlocal
	exit /b
	goto endscript
)

:3
for %%v in (6.1 6.2 6.3 10.0) do ( if "%version%" == "%%v" setlocal EnableExtensions EnableDelayedExpansion )
set "BASEDIR=%~dp0"
set "ORIG_PATH=%PATH%"
set "PATH=%BASEDIR%\bin;%PATH%"
set "errorp=ERROR:"
set "cautionp=CAUTION:"
set "infop=INFORMATION:"
cd /d "%~dp0"

if exist "%BASEDIR%\bin\adb.exe"  (
	echo ADB installed on Console Toolkit.
	echo Starting ADB service...
	adb start-server
)


:main-menu
@echo off
for %%v in (
	reboot_recovery recovery_adb recovery_fastboot
	reboot_system reboot_adb reboot_fastboot
	reboot_bootloader bootloader_adb bootloader_fastboot
	adbfastboot_notfound no_connection codename_false
	largest_anti error no_mount choice
	rootsel rootzip twrp_exit root_exit
	MOUNT_SCRIPT UNMOUNT_SCRIPT
) do ( set "%%v=" )
break off
cls
color 1f
echo.
echo MAIN MENU
echo ����������
echo.
echo Current state:
adb devices 2>&1 | findstr /r /c:"device\>" || (
adb devices 2>&1 | findstr /r /c:"recovery\>" || (
fastboot devices 2>&1 | findstr /r /c:"fastboot\>" || (
	echo Nothing device connection.
	echo Plug your device to PC with USB cable and press ENTER to refresh.
) ) )
echo.
echo.
echo    1.^)  Check the bootloader status
echo    2.^)  Flash TWRP ^(Custom recovery^)
echo    3.^)  Flash Disable DM-Verity and Force Encryption
echo    4.^)  Flash Camera2 API Enabler
echo    5.^)  Flash Root
echo    6.^)  Emulate the device shell
echo    7.^)  Reboot to system
echo    8.^)  Reboot to bootloader
echo    9.^)  Reboot to recovery
echo    0.^)  Switch ADB Connection
echo.
echo    A.^)  Run ADB Devices installer
echo    B.^)  Install Java Runtime Environment
echo    C.^)  Install ADB and Fastboot programs
echo    H.^)  Show help and about this program
echo    Q.^)  Exit this program
echo.
set /p "choice=Choose your option: "
echo.
if [%choice%] EQU []  goto main-menu
for %%a in (D d E e F f G g I i J j K k L l M m N n O o P p R r S s T t U u V v W w X x Y y Z z) do (
	if [%choice%] == [%%a] goto main-menu
)
if [%choice%] LEQ []  goto main-menu
for %%a in (Q q) do (
	if [%choice%] == [%%a]  (
		call :end1
		exit /b
		goto endscript
	)
)
for %%a in (H h) do (
	if [%choice%] == [%%a]  goto :help
)
for %%a in (C c) do (
	if [%choice%] == [%%a]  goto :adbfastboot
)
for %%a in (B b) do (
	if [%choice%] == [%%a]  goto :jdk
)
for %%a in (A a) do (
	if [%choice%] == [%%a]  goto :adbinstaller
)
if [%choice%] == [0]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	call :check-devices1
	if defined no_connection goto main-menu
	call :switch-adb
	if defined back goto main-menu
	call :end2
	goto main-menu
)
if [%choice%] == [9]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	set "reboot_recovery=1"
	echo Trying reboot from normal state...
	call :check-devices1
	if defined no_connection (
		echo Trying reboot from recovery state...
		call :check-devices2
		if defined no_connection (
			echo Trying reboot from fastboot state...
			call :check-fastboot
			if defined no_connection (
				call :end2
				goto main-menu
			)
		)
	)
	call :reboot-recovery
	call :end2
	goto main-menu
)
if [%choice%] == [8]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	set "reboot_bootloader=1"
	echo Trying reboot from normal state...
	call :check-devices1
	if defined no_connection (
		echo Trying reboot from recovery state...
		call :check-devices2
		if defined no_connection (
			echo Trying reboot from fastboot state...
			call :check-fastboot
			if defined no_connection (
				call :end2
				goto main-menu
			)
		)
	)
	call :reboot-bootloader
	call :end2
	goto main-menu
)
if [%choice%] == [7]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	set "reboot_system=1"
	echo Trying reboot from normal state...
	call :check-devices1
	if defined no_connection (
		echo Trying reboot from recovery state...
		call :check-devices2
		if defined no_connection (
			echo Trying reboot from fastboot state...
			call :check-fastboot
			if defined no_connection (
				call :end2
				goto main-menu
			)
		)
	)
	call :reboot-systemdevices
	call :end2
	goto main-menu
)
if [%choice%] == [6]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	echo Trying connect from normal state...
	call :check-devices1
	if defined no_connection (
		echo Trying connect from recovery state...
		call :check-devices2
		if defined no_connection (
			call :end2
			goto main-menu
		)
	)
	echo To terminate from shell, type 'exit'...
	adb shell
	call :end2
	goto main-menu
)
if [%choice%] == [5]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	call :flash-root
	if defined root_exit goto main-menu
	call :end2
	goto main-menu
)
if [%choice%] == [4]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	call :check-sideload
	if defined no_connection goto main-menu
	call :flash-cam2api
	if defined no_mount goto main-menu
	call :end2
	goto main-menu
)
if [%choice%] == [3]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	call :check-sideload
	if defined no_connection goto main-menu
	call :flash-lazy
	call :end2
	goto main-menu
)
if [%choice%] == [2]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	call :check-fastboot
	if defined no_connection goto main-menu
	call :check-codename
	if defined codename_false goto main-menu
	call :check-antirollback
	if defined largest_anti goto main-menu
	if defined error goto main-menu
	call :flash-twrp
	if defined twrp_exit goto main-menu
	call :end2
	goto main-menu
)
if [%choice%] == [1]  (
	call :startopt
	call :check-adb
	if defined adbfastboot_notfound goto main-menu
	call :check-fastboot
	if defined no_connection goto main-menu
	call :check-codename
	if defined codename_false goto main-menu
	call :check-unlock
	call :end2
	goto main-menu
)



:startopt
echo ------------------------------------ START ------------------------------------
goto :eof

:adbinstaller
call "%BASEDIR%\bin\adb-drivers_installer.exe"
goto main-menu

:adbfastboot
for %%f in ('adb' 'fastboot') do ( if exist "%BASEDIR%\bin\%%f.exe" (
	echo %infop%  ADB and Fastboot already installed. )
	timeout /t 2 /nobreak >nul
	goto main-menu
)
if not exist "%BASEDIR%\bin\pkg\android-platform-tools-win.zip" (
	wget -O "%BASEDIR%\bin\pkg\android-platform-tools-win.zip" https://dl.google.com/android/repository/platform-tools_r28.0.1-windows.zip?hl=id
)
7z -ao -x -o "%BASEDIR%\bin" "%BASEDIR%\bin\pkg\android-platform-tools-win.zip"
echo d | xcopy "%BASEDIR%\bin\platform-tools" "%BASEDIR%\bin"
del /sq "%BASEDIR%\bin\platform-tools"
for %%f in ('adb' 'fastboot') do ( if exist "%BASEDIR%\bin\%%f.exe" (
	echo %infop%  ADB and Fastboot successfully installed. ) else (
	echo %errorp%  Failed installed. Please try again. )
	pause
)
goto main-menu

:jdk
if not exist "%BASEDIR%\bin\pkg\jre_installer.exe"  (
	wget -O "%BASEDIR%\bin\pkg\jre_installer.exe" https://javadl.oracle.com/webapps/download/AutoDL?BundleId=242088_3d5a2bb8f8d4428bbe94aed7ec7ae784
)
call "%BASEDIR%\bin\pkg\jre_installer.exe"
goto main-menu

:help
cls
echo This program was written and created by Faizal Hamzah with the aim of
echo making it easier for users to do the work of modifying Android mobile
echo devices. Facilities of this program, include^:
echo.
echo   1.  Check the status bootloader ^(e.g. Unlock and Lock^)
echo   2.  Flash custom reecovery^/TWRP
echo   3.  Flash Disable DM-Verity and Force Encryption
echo   4.  Flash Camera2 API Enabler
echo   5.  Flash Root Access
echo   6.  Run Terminal Android in PC
echo   7.  Switch ADB Connection
echo.
echo This program is only for those who have a Xiaomi Redmi Note 5
echo Global^/Pro phone ^(codename^: Whyred^)
echo.
echo Special thanks^:
echo ^>  Google - Android
echo ^>  TWRP team
echo ^>  Orangefox team
echo ^>  PitchBlack team
echo ^>  Magisk team
echo ^>  XDA
echo ^>  Xiaomi Flashing Team
echo ^>  and the users Xiaomi Redmi Note 5 Global^/Pro
echo.
pause
cls
echo Contact person^:
echo ^> https^:^/^/api.whatsapp.com^/send^?phone^=6288228419117
echo ^> https^:^/^/www.facebook.com^/thefirefoxflasher
echo ^> https^:^/^/www.instagram.com^/thefirefoxflasher^_
echo.
pause
goto main-menu



:check-adb
echo Checking ADB and Fastboot programs...
for %%f in ('adb' 'fastboot') do ( if exist "%BASEDIR%\bin\%%f.exe" (
	echo %errorp%  ADB and Fastboot not installed.
	set "adbfastboot_notfound=1"
	call :end2
) )
goto :eof

:check-devices1
if defined back (
	echo Reconnecting...
	set "back="
) else ( echo Checking connection... )
set no_connection=
for %%v in (reboot_recovery reboot_system reboot_bootloader) do ( if defined %%v adb wait-for-device )
adb devices 2>&1 | findstr /r /c:"device\>" || (
	echo %errorp%  Your device not connected. Check the driver or USB debugging.
	choice /c yn /n /m "Try again? [Y/N] "
	if errorlevel 2 (
		set "no_connection=1"
		if [%reboot_recovery%] == [1]	 goto :eof
		if [%reboot_system%] == [1]		 goto :eof
		if [%reboot_bootloader%] == [1]	 goto :eof
		call :end2
		goto :eof
	)
	set "back=1"
	goto check-devices1
)
if [%reboot_recovery%] == [1]	 set "recovery_adb=1"
if [%reboot_system%] == [1]		 set "reboot_adb=1"
if [%reboot_bootloader%] == [1]	 set "bootloader_adb=1"
goto :eof

:check-devices2
if defined back (
	echo Reconnecting...
	set "back="
) else ( echo Checking connection... )
set no_connection=
for %%v in (reboot_recovery reboot_system reboot_bootloader) do ( if defined %%v adb wait-for-recovery )
adb devices 2>&1 | findstr /r /c:"recovery\>" || (
	echo %errorp%  Your device not connected in recovery. Check the driver or reboot recovery again.
	choice /c yn /n /m "Try again? [Y/N] "
	if errorlevel 2 (
		set "no_connection=1"
		if [%reboot_recovery%] == [1]	 goto :eof
		if [%reboot_system%] == [1]		 goto :eof
		if [%reboot_bootloader%] == [1]	 goto :eof
		call :end2
		goto :eof
	)
	set "back=1"
	goto check-devices2
)
if [%reboot_recovery%] == [1]	 set "recovery_adb=1"
if [%reboot_system%] == [1]		 set "reboot_adb=1"
if [%reboot_bootloader%] == [1]	 set "bootloader_adb=1"
goto :eof

:switch-adb
set "no_connection="
if not defined ipaddrs echo Identifying IP Address from your device...
for /f "tokens=2 delims= " %%i in ('adb shell ip addr^| findstr "wlan0"^| findstr "inet"') do ( set "ipaddrs=%%i" )
for /f "tokens=1 delims=/" %%i in ("%ipaddrs%") do ( set "ipaddrs=%%i" )
set tcport=5555
adb devices | findstr /r /c:"%ipaddrs%:%tcport%" >nul 2>&1
if [%errorlevel%] EQU [0] (
	echo %infop%  Your device already connected on network.
	choice /c yn /n /m "Do you want to disable ADB Network? [Y/N] "
	set "back=1"
	if errorlevel 2 goto :eof
	echo.
	echo Disconnecting ADB from network...
	adb disconnect >nul
	echo Please plug USB cable on this PC and your device.
	pause
	echo Connecting...
	adb wait-for-device
	adb usb 2>&1 || (
		echo %errorp%  Connected failure. Please try again.
		call :end2
		goto :eof
	)
	echo Successfully disconnected.
	for %%v in ('tcport' 'ipaddrs') do ( set "%%v=" )
	call :end2
	goto :eof
) else (
	echo Disconnecting ADB from USB...
	adb disconnect >nul
	adb tcpip %tcport%
	echo Please unplug USB cable on this PC and your device.
	pause
	echo Connecting to your IP Address and ADB Server Port...
	adb connect %ipaddrs%:%tcport%
	adb wait-for-device
	adb devices 2>&1 | findstr /r /c:"%ipaddrs%:%tcport%" || (
		echo %errorp%  Connected failure. Plug your device and try again.
		adb usb 2>&1
		goto :eof
	)
	echo %infop%  Success connected. To back the USB, disable network at your device.
	call :end2
	goto :eof
)

:check-fastboot
echo Checking fastboot connection...
set no_connection=
fastboot devices 2>&1 | findstr /r /c:"fastboot\>" || (
	echo %errorp%  Your device not connected.
	set "no_connection=1"
	if [%reboot_recovery%] == [1]	 goto :eof
	if [%reboot_system%] == [1]		 goto :eof
	if [%reboot_bootloader%] == [1]	 goto :eof
	call :end2
	goto :eof
)
if [%reboot_recovery%] == [1]	 set "recovery_fastboot=1"
if [%reboot_system%] == [1]		 set "reboot_fastboot=1"
if [%reboot_bootloader%] == [1]	 set "bootloader_fastboot=1"
goto :eof

:check-codename
echo Checking require codename devices...
fastboot getvar product 2>&1 | findstr /r /c:"^product: *whyred" || (
	echo %errorp%  Your device is not Xiaomi Redmi Note 5^/Pro. The code must 'whyred'.
	set "codename_false=1"
	call :end2
)
goto :eof

:check-unlock
echo Checking the device unlocked bootloader...
set "CURRENT_RESULT=true"
for /f "tokens=4 delims=: " %%i in ('fastboot oem device-info 2^>^&1 ^| findstr /r /c:"Device unlocked:"') do ( set "result=%%i" )
if [%result%] EQU [] set "result=false"
if [%result%] NEQ [%CURRENT_RESULT%] (
	echo %infop%  Your device locked bootloader.
	echo.
	echo This script will be unlock using Mi Unlock Tool. For unlock bootloader^:
	echo   -  You must have a Mi Account.
	echo   -  Activate OEM unlock, USB debugging and request the Mi Account
	echo      permission to be authorized in developer options ^> Mi Unlock
	echo      Status.
	echo.
	echo If not yet do it, follow this instruction and run this again.
	choice /c yn /n /m "Are you ready? [Y/N] "
	if errorlevel 2 goto :eof
	call :find-java
	call :unlock-bootloader
) else if [%result%] EQU [%CURRENT_RESULT%] (
	echo %infop%  Your device already unlock bootloader.
	choice /c yn /n /m "Do you want to lock bootloader? [Y/N] "
	if errorlevel 2  goto :eof
	fastboot oem lock 2>&1 || echo %errorp%  Failed locked.
)
goto :eof

:find-java
if defined JAVA_HOME goto find-JavaFromJavaHome
set JAVA_EXE=java.exe
%JAVA_EXE% -version >nul 2>&1
if [%errorlevel%] EQU [0] goto :eof
goto NoJava
:find-JavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%\bin\java.exe
if exist "%JAVA_EXE%" goto :eof
:NoJava
echo Mi Unlock Tool requires Java Runtime Environment. So install it first
echo before unlocking bootloader.
goto :eof

:unlock-bootloader
if not exist "%BASEDIR%\bin\Mi-Unlock-Tool.jar"  (
	wget -O "%BASEDIR%\tmp\Mi-Unlock-Tool.zip" http://us1.fastandroid.download/tool/MiUnlock-Linux-Mac.zip
	7z -ao -x -o "%BASEDIR%\tmp" "%BASEDIR%\tmp\Mi-Unlock-Tool.zip" MiUnlockTool\bin\MiUnlockTool.jar
	move "%BASEDIR%\tmp\MiUnlockTool\bin\MiUnlockTool.jar" "%BASEDIR%\bin\Mi-Unlock-Tool.jar"
	del /sq "%BASEDIR%\tmp\MiUnlockTool"
	del /q "%BASEDIR%\tmp\Mi-Unlock-Tool.zip"
)
:userloop
set /p "mi_username=Type your Mi Account username/email/phone: "
if [%mi_username%] == []  goto userloop
:pwdloop
echo Set oScriptPW ^= CreateObject^("ScriptPW.Password"^) >"%BASEDIR%\tmp\getpwd.vbs"
echo strPassword ^= oScriptPW.GetPassword^(^) >>"%BASEDIR%\tmp\getpwd.vbs"
echo WScript.StdOut.WriteLine strPassword >>"%BASEDIR%\tmp\getpwd.vbs"
< nul: set /p "mi_password=Type your Mi Account password: "
for /f "delims=" %%i in ('cscript /nologo "%BASEDIR%\tmp\getpwd.vbs"') do ( set "mi_password=%%i" )
del "%BASEDIR%\tmp\getpwd.vbs"
if [%mi_password%] == []  goto pwdloop
:prompt_erasedata
choice /c yn /n /m "Unlocking bootloader that will erase all data. Do you agree? [Y/N] "
if errorlevel 2 goto :eof
:run_MiUnlock
%JAVACMD% -jar "%BASEDIR%\bin\Mi-Unlock-Tool.jar" %mi_username% %mi_password%
goto :eof

:check-antirollback
echo Checking device antirollback version...
set "CURRENT_ANTI_VER=4"
for /f "tokens=2 delims=: " %%i in ('fastboot getvar anti 2^>^&1 ^| findstr /r /c:"anti:"') do ( set "arbver=%%i" )
if [%arbver%] EQU [] set "arbver=0"
if [%arbver%] GTR [%CURRENT_ANTI_VER%] (
	echo %errorp%  Current device antirollback version is greater than this package.
	set "largest_anti=1"
	call :end2
	goto :eof
)
if [%arbver%] EQU [%CURRENT_ANTI_VER%] fastboot flash antirbpass "%BASEDIR%\recovery\dummy.img" || (
	echo %errorp%  Failed flash 'antirbpass'.
	set "error=1"
	call :end2
	goto :eof
)
echo %infop%  Flash 'antirbpass' success.
goto :eof

:flash-twrp
@echo off
break off
cls
echo.
echo FLASH TWRP
echo �����������
echo.
echo.
echo    1.^)  Team Win Recovery Project
echo    2.^)  Orange Fox Recovery
echo    3.^)  PitchBlack Recovery Project
echo.
echo    A.^)  Let me choose
echo    Q.^)  Back to main menu
echo.
set choice=
set /p "choice=Select TWRP version: "
echo.
if [%choice%] EQU []  goto flash-twrp
for %%a in (B b C c D d E e F f G g H h I i J j K k L l M m N n O o P p R r S s T t U u V v W w X x Y y Z z) do (
	if [%choice%] == [%%a] goto flash-twrp
)
if [%choice%] LEQ []  goto flash-twrp
for %%a in (4 5 6 7 8 9 0) do (
	if [%choice%] == [%%a]  goto flash-twrp
)
for %%a in (Q q) do (
	if [%choice%] == [%%a]  (
		set "twrp_exit=1"
		goto :eof
	)
)
for %%a in (A a) do (
	if [%choice%] == [%%a]  (
		:type
		set /p "recoveryimg=Type an img file (with directory): "
		if not exist "%recoveryimg%" (
			echo Img file not found.
			goto type
		)
	)
)
if [%choice%] == [3]  (
	if not exist "%BASEDIR%\recovery\pbrp.img" (
		wget -O "%BASEDIR%\tmp\pbrp.zip" https://udomain.dl.sourceforge.net/project/pbrp/whyred/PBRP-whyred-3.0.0-20200801-1730-OFFICIAL.zip
		7z -ao -x -o "%BASEDIR%\recovery" "%BASEDIR%\tmp\pbrp.zip" TWRP\recovery.img
		move "%BASEDIR%\recovery\TWRP\recovery.img" "%BASEDIR%\recovery\pbrp.img"
		del /sq "%BASEDIR%\recovery\TWRP"
		del /q "%BASEDIR%\tmp\pbrp.zip"
	)
	set "recoveryimg=%BASEDIR%\recovery\pbrp.img"
if [%choice%] == [2]  (
	if not exist "%BASEDIR%\recovery\ofox.img" (
		wget -O "%BASEDIR%\tmp\ofox.zip" https://files.orangefox.tech/OrangeFox-Beta/whyred/OrangeFox-R11.0_1-Beta-whyred.zip
		7z -ao -x -o "%BASEDIR%\recovery" "%BASEDIR%\tmp\ofox.zip" recovery.img
		move "%BASEDIR%\recovery\recovery.img" "%BASEDIR%\recovery\ofox.img"
		del /q "%BASEDIR%\tmp\ofox.zip"
	)
	set "recoveryimg=%BASEDIR%\recovery\ofox.img"
if [%choice%] == [1]  (
	if not exist "%BASEDIR%\recovery\twrp.img" wget -O "%BASEDIR%\recovery\twrp.img" https://dl.twrp.me/whyred/twrp-3.4.0-0-whyred.img
	set "recoveryimg=%BASEDIR%\recovery\twrp.img"
)
fastboot flash recovery "%recoveryimg%" || (
	echo %errorp%  Failed flash TWRP.
	call :end2
	goto :eof
)
echo %infop%  Flash 'recovery' success.
goto :eof

:check-sideload
set no_connection=
echo %cautionp%  Select ADB Sideload on Recovery menu ^> Advanced, then swipe and automatically flash.
:sideloadloop
adb wait-for-sideload
adb devices 2>&1 | findstr /r /c:"sideload\>" || (
	echo %errorp%  Your device not connected in sideload. Check the driver or reboot recovery again.
	choice /c yn /n /m "Try again? [Y/N] "
	if errorlevel 2 (
		set "no_connection=1"
		call :end2
		goto :eof
	)
	goto sideloadloop
)
goto :eof

:flash-lazy
echo Installing Lazyflasher...
adb sideload "%BASEDIR%\data\lazyflasher.zip"
goto :eof

:flash-cam2api
echo Installing Camera2 API Enabler...
adb sideload "%BASEDIR%\data\cam2api-enabler.zip"
>nul 2>&1 timeout /t 5 /nobreak
echo Patching build.prop script...

:mount-system
set "MOUNT_SCRIPT=mount-system.sh"
set "UNMOUNT_SCRIPT=unmount-system.sh"
echo Mounting /system...
>nul 2>&1 adb push "%BASEDIR%\data\%MOUNT_SCRIPT%" /tmp/
>nul 2>&1 adb push "%BASEDIR%\data\%UNMOUNT_SCRIPT%" /tmp/
>nul 2>&1 adb shell "chmod 0755 /tmp/%MOUNT_SCRIPT%"
>nul 2>&1 adb shell "chmod 0755 /tmp/%UNMOUNT_SCRIPT%"
adb shell "/sbin/sh /tmp/%MOUNT_SCRIPT%"
for %%s in (
	/system /system/system
	/system_root /system_root/system
) do ( >nul 2>&1 adb pull %%s/build.prop "%BASEDIR%\tmp\build.prop" )
if not exist "%BASEDIR%\tmp\build.prop" (
	echo %errorp%  /system not yet mounted.
	choice /c yn /n /m "Try again? [Y/N] "
	if errorlevel 2 (
		call :unmount-system
		set "no_mount=1"
		call :end2
		goto :eof
	)
	goto mount-system
) else ( del /q "%BASEDIR%\tmp\build.prop" )

:write-prop
adb push "%BASEDIR%\data\patch.sh" /tmp/
adb shell "chmod 0755 /tmp/patch.sh"
adb shell "/sbin/sh /tmp/patch.sh"

:unmount-system
echo Unmounting /system...
adb shell "/sbin/sh /tmp/%UNMOUNT_SCRIPT%"
>nul 2>&1 adb shell "rm -rf /tmp/*"
goto :eof

:flash-root
@echo off
break off
cls
echo.
echo INSTALL ROOT
echo �������������
echo.
echo    1.^)  SuperSU
echo    2.^)  Magisk
echo.
echo    Q.^)  Back to main menu
echo.
set choice=
set /p "choice=Select TWRP version: "
echo.
if [%choice%] EQU []  goto flash-root
for %%a in (A a B b C c D d E e F f G g H h I i J j K k L l M m N n O o P p R r S s T t U u V v W w X x Y y Z z) do (
	if [%choice%] == [%%a] goto flash-root
)
if [%choice%] LEQ []  goto flash-root
for %%a in (3 4 5 6 7 8 9 0) do (
	if [%choice%] == [%%a]  goto flash-root
)
for %%a in (Q q) do (
	if [%choice%] == [%%a]  (
		set "root_exit=1"
		goto :eof
	)
)
call :check-sideload
if [%choice%] == [2]  (
	if not exist "%BASEDIR%\data\magisk.zip" wget -O "%BASEDIR%\data\magisk.zip" https://github.com/topjohnwu/Magisk/releases/download/v20.4/Magisk-v20.4.zip
	set "rootsel=Magisk"
	set "rootzip=%BASEDIR%\data\magisk.zip"
)
if [%choice%] == [1]  (
	if not exist "%BASEDIR%\data\supersu.zip" wget -O "%BASEDIR%\data\supersu.zip" http://supersuroot.org/downloads/SuperSU-v2.82-201705271822.zip
	set "rootsel=SuperSU"
	set "rootzip=%BASEDIR%\data\supersu.zip"
)
echo Installing %rootsel%...
>nul 2>&1 adb sideload "%rootzip%"
call :end2
goto :eof

:reboot-systemdevices
echo Rebooting...
if [%reboot_fastboot%] == [1]		( set "do_reboot_system=fastboot reboot"
) else if [%reboot_adb%] == [1]		( set "do_reboot_system=adb reboot" )
>nul 2>&1 %do_reboot_system% || echo %errorp%  Cannot reboot.
goto :eof

:reboot-bootloader
echo Rebooting to bootloader...
if [%bootloader_fastboot%] == [1]		( set "do_reboot_bootloader=fastboot reboot bootloader"
) else if [%bootloader_adb%] == [1]		( set "do_reboot_bootloader=adb reboot bootloader" )
>nul 2>&1 %do_reboot_bootloader% || echo %errorp%  Cannot reboot to bootloader.
goto :eof

:reboot-recovery
if [%recovery_fastboot%] == [1] (
	if not defined recoveryimg  set "recoveryimg=%BASEDIR%\recovery\twrp.img"
	if "%recoveryimg%"==""      set "recoveryimg=%BASEDIR%\recovery\twrp.img"
	echo Booting to recovery...
	set "do_reboot_recovery=fastboot boot ""%recoveryimg%"""
) else if [%recovery_adb%] == [1] (
	echo Rebooting to recovery...
	set "do_reboot_recovery=adb reboot recovery"
)
%do_reboot_recovery% || echo %errorp%  Cannot reboot to recovery. && set "error=1"
if not defined error if [%recovery_fastboot%] == [1] if not defined error  echo %infop%  Download 'recovery' to 'boot' success.
goto :eof


:end1
if exist "%BASEDIR%\bin\adb.exe"  (
	echo Exiting from program...
	echo Closing ADB service...
	>nul 2>&1 adb kill-server
	set "PATH=%ORIG_PATH%"
)
pause
endlocal
cls
color
exit /b
goto endscript

:end2
echo ------------------------------------- END -------------------------------------
pause
exit /b
goto endscript




:dos
echo This program cannot be run in DOS mode.
goto endscript

:winos2
echo This script requires Microsoft Windows NT.
goto endscript

:nt
echo This script requires a newer version of Windows NT.
endlocal

:: END



::
:: COMMENTS
::

::
:: This program was written and created by Faizal Hamzah with the aim of making
:: it easier for users to do the work of modifying Android mobile devices.
::
:: Facilities of this program, include:
::   1.  Check the status bootloader (e.g. Unlock and Lock)
::   2.  Flash custom reecovery/TWRP
::   3.  Flash Disable DM-Verity and Force Encryption
::   4.  Flash Camera2 API Enabler
::   5.  Flash Root Access
::   6.  Run Terminal Android in PC
::   7.  Switch ADB Connection
::
:: This program is only for those who have a Xiaomi Redmi Note 5 Global/Pro
:: phone (codename: Whyred)
::
:: Special thanks:
:: >  Google - Android
:: >  TWRP team
:: >  Orangefox team
:: >  PitchBlack team
:: >  Magisk team
:: >  XDA
:: >  Xiaomi Flashing Team
:: >  and the users Xiaomi Redmi Note 5 Global/Pro
::

:ENDSCRIPT
@ECHO ON
