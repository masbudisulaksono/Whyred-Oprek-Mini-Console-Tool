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
:: Whyred Oprek Mini Console Tool
::
:: Date/Time Created:          06/14/2020  10:34pm
:: Date/Time Modified:         06/18/2020  1:38am
:: Operating System Created:   Windows 10 Pro
::
:: This script created by:
::   Faizal Hamzah
::   The Firefox Foundation
::
::
:: VersionInfo:
::
::    File version:      1,0
::    Product Version:   1,0
::
::    CompanyName:       The Firefox Flasher
::    FileDescription:   Make it easier to modified the Xiaomi Redmi Note 5 Global/Pro device.
::    FileVersion:       1.0
::    InternalName:      runit
::    LegalCopyright:    The Firefox Foundation
::    OriginalFileName:  runit.sh
::    ProductName:       Whyred Oprek Mini Console Tool
::    ProductVersion:    1.0
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
   echo Please run this script as administrator user mode
   echo or with an administrative privileges access.
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
for %%v in (6.1 6.2 6.3 10.0) do ( if "%version%" == "%%v" (
   setlocal enableextensions
   setlocal enabledelayedexpansion )
)
set "errorp=ERROR:"
set "cautionp=CAUTION:"
set "infop=INFORMATION:"
cd /d "%~dp0"

echo Starting ADB service...
>nul 2>&1 adb start-server


:main-menu
@echo off
for %%v in (
   reboot_recovery recovery_adb recovery_fastboot
   reboot_system reboot_adb reboot_fastboot
   reboot_bootloader bootloader_adb bootloader_fastboot
   adbfastboot_notfound no_connection codename_false
   largest_anti error no_mount choice
   rootsel rootzip twrp_exit root_exit
) do ( set "%%v=" )
break off
cls
color 1f
echo.
echo MAIN MENU
echo ออออออออออ
echo.
echo Current state:
adb devices 2>&1 | findstr /r /c:"device\>"
if [%errorlevel%] NEQ [0] adb devices 2>&1 | findstr /r /c:"recovery\>"
if [%errorlevel%] NEQ [0] fastboot devices 2>&1 | findstr /r /c:"fastboot\>"
if [%errorlevel%] NEQ [0] echo No connection. Please connect your device to PC.
echo.
echo.
echo    1.^)  Check the bootloader status
echo    2.^)  Flash TWRP
echo    3.^)  Flash Lazyflasher ^(Disable DM-Verity and Force Encryption^)
echo    4.^)  Flash Camera2 API Enabler
echo    5.^)  Flash Root
echo    6.^)  Install Manual Camera Compatibility Test APK
echo    7.^)  Reboot to system
echo    8.^)  Reboot to bootloader
echo    9.^)  Reboot to recovery
echo.
echo    A.^)  Run ADB Devices installer
echo    B.^)  Install ADB and Fastboot programs
echo    H.^)  Show help and about this program
echo    Q.^)  Exit this program
echo.
set /p "choice=Choose your option: "
echo.
if [%choice%] EQU []  goto main-menu
for %%a in (C c D d E e F f G g I i J j K k L l M m N n O o P p R r S s T t U u V v W w X x Y y Z z) do (
   if [%choice%] == [%%a] goto main-menu
)
if [%choice%] LEQ []  goto main-menu
if [%choice%] == [0]  goto main-menu
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
for %%a in (B b) do (
   if [%choice%] == [%%a]  goto :adbfastboot
)
for %%a in (A a) do (
   if [%choice%] == [%%a]  goto :adbinstaller
)
if [%choice%] == [9]  (
   call :startopt
   call :check-adb
   if defined adbfastboot_notfound goto main-menu
   set "reboot_recovery=1"
   call :check-devices1
   if defined no_connection (
      call :check-devices2
      if defined no_connection (
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
   call :check-devices1
   if defined no_connection (
      call :check-devices2
      if defined no_connection (
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
   call :check-devices1
   if defined no_connection (
      call :check-devices2
      if defined no_connection (
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
   call :check-devices1
   if defined no_connection goto main-menu
   call :manualcam
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
call "%~dp0bin\adb-drivers_installer.exe"
goto main-menu

:adbfastboot
if exist "%SystemRoot%\adb-fastboot.dat" (
   echo The program already installed.
   timeout /t 2 /nobreak >nul
   goto main-menu
)
call "%~dp0bin\adb-and-fastboot_installer.exe"
echo ADB and Fastboot >%SystemRoot%\adb-fastboot.dat
goto main-menu

:help
cls
echo This program was written and created by Faizal Hamzah with the aim of making
echo it easier for users to do the work of modifying Android mobile devices.
echo.
echo Facilities of this program, include^:
echo   1.  Check the bootloader
echo   2.  Flash TWRP
echo   3.  Flash LazyFlasher
echo   4.  Flash Camera2 API
echo   5.  Flash Root Access
echo.
echo This program is only for those who have a Xiaomi Redmi Note 5 Global^/Pro
echo phone ^(codename^: Whyred^)
echo.
pause
cls
echo Special thanks:
echo ^>  Google - Android
echo ^>  TWRP team
echo ^>  Orangefox team
echo ^>  PitchBlack team
echo ^>  Magisk team
echo ^>  XDA
echo ^>  Xiaomi Flashing Team
echo ^>  and the users Xiaomi Redmi Note 5 Global/Pro
echo.
pause
goto main-menu



:check-adb
echo Checking ADB and Fastboot programs...
if not exist "%SystemRoot%\adb-fastboot.dat" (
   echo %errorp%  ADB and Fastboot not installed.
   set "adbfastboot_notfound=1"
   call :end2
)
goto :eof

:check-devices1
echo Checking connection...
set no_connection=
adb devices 2>&1 | findstr /r /c:"device\>" || (
   echo %errorp%  Your device not connected. Check the driver or USB debugging.
   choice /c yn /n /m "Try again? [Y/N] "
   if errorlevel 2 (
      set "no_connection=1"
      if [%reboot_recovery%] == [1]    goto :eof
      if [%reboot_system%] == [1]      goto :eof
      if [%reboot_bootloader%] == [1]  goto :eof
      call :end2
      goto :eof
   )
   goto check-devices1
)
if [%reboot_recovery%] == [1]    set "recovery_adb=1"
if [%reboot_system%] == [1]      set "reboot_adb=1"
if [%reboot_bootloader%] == [1]  set "bootloader_adb=1"
goto :eof

:check-devices2
echo Checking connection...
set no_connection=
:loop1
adb devices 2>&1 | findstr /r /c:"recovery\>" || (
   echo %errorp%  Your device not connected in recovery. Check the driver or reboot recovery again.
   choice /c yn /n /m "Try again? [Y/N] "
   if errorlevel 2 (
      set "no_connection=1"
      if [%reboot_recovery%] == [1]    goto :eof
      if [%reboot_system%] == [1]      goto :eof
      if [%reboot_bootloader%] == [1]  goto :eof
      call :end2
      goto :eof
   )
   goto loop1
)
if [%reboot_recovery%] == [1]    set "recovery_adb=1"
if [%reboot_system%] == [1]      set "reboot_adb=1"
if [%reboot_bootloader%] == [1]  set "bootloader_adb=1"
goto :eof

:check-fastboot
echo Checking fastboot connection...
set no_connection=
fastboot devices 2>&1 | findstr /r /c:"fastboot\>" || (
   echo %errorp%  Your device not connected.
   set "no_connection=1"
   if [%reboot_recovery%] == [1]    goto :eof
   if [%reboot_system%] == [1]      goto :eof
   if [%reboot_bootloader%] == [1]  goto :eof
   call :end2
   goto :eof
)
if [%reboot_recovery%] == [1]    set "recovery_fastboot=1"
if [%reboot_system%] == [1]      set "reboot_fastboot=1"
if [%reboot_bootloader%] == [1]  set "bootloader_fastboot=1"
goto :eof

:check-codename
echo Checking require codename devices...
fastboot %* getvar product 2>&1 | findstr /r /c:"^product: *whyred" || (
   echo %errorp%  Your device is not Xiaomi Redmi Note 5^/Pro. The code must 'whyred'.
   set "codename_false=1"
   call :end2
)
goto :eof

:check-unlock
echo Checking the device unlocked bootloader...
set "CURRENT_RESULT=true"
for /f "tokens=4 delims=: " %%i in ('fastboot %* oem device-info 2^>^&1 ^| findstr /r /c:"Device unlocked:"') do ( set "result=%%i" )
if [%result%] EQU [] set "result=false"
if [%result%] NEQ [%CURRENT_RESULT%] (
   echo %errorp%  Your device is lock bootloader.
) else if [%result%] EQU [%CURRENT_RESULT%] (
   echo %infop%  Your device already unlock bootloader.
)
goto :eof

:check-antirollback
echo Checking device antirollback version...
set "CURRENT_ANTI_VER=4"
for /f "tokens=2 delims=: " %%i in ('fastboot %* getvar anti 2^>^&1 ^| findstr /r /c:"anti:"') do ( set "arbver=%%i" )
if [%arbver%] EQU [] set "arbver=0"
if [%arbver%] GTR [%CURRENT_ANTI_VER%] (
   echo %errorp%  Current device antirollback version is greater than this package.
   set "largest_anti=1"
   call :end2
   goto :eof
)
if [%arbver%] EQU [%CURRENT_ANTI_VER%] (
   fastboot %* flash antirbpass .\recovery\dummy.img || (
      echo %errorp%  Failed flash 'antirbpass'.
      set "error=1"
      call :end2
      goto :eof
   )
)
echo %infop%  Flash 'antirbpass' success.
goto :eof

:flash-twrp
@echo off
break off
cls
echo.
echo FLASH TWRP
echo อออออออออออ
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
if [%choice%] == [Q]  (
   set "twrp_exit=1"
   goto :eof
)
if [%choice%] == [q]  (
   set "twrp_exit=1"
   goto :eof
)
if [%choice%] == [A]  (
:type
   echo Type a img file ^(with directory if there in outside^)
   set /p "recoveryimg=>"
   if not exist "%recoveryimg%" (
      echo Img file not found.
      goto type
   )
   goto :eof
)
if [%choice%] == [a]  goto type
if [%choice%] == [3]  set "recoveryimg=.\recovery\pbrp.img"
if [%choice%] == [2]  set "recoveryimg=.\recovery\ofox.img"
if [%choice%] == [1]  set "recoveryimg=.\recovery\twrp.img"
fastboot %* flash recovery %recoveryimg% || (
   echo %errorp%  Failed flash TWRP.
   call :end2
   goto :eof
)
echo %infop%  Flash 'recovery' success.
goto :eof

:check-sideload
set no_connection=
echo %cautionp%  Before execution, select ADB Sideload first on recovery.
pause
:loop2
adb devices 2>&1 | findstr /r /c:"sideload\>" || (
   echo %errorp%  Your device not connected in sideload. Check the driver or reboot recovery again.
   choice /c yn /n /m "Try again? [Y/N] "
   if errorlevel 2 (
      set "no_connection=1"
      call :end2
      goto :eof
   )
   goto loop2
)
goto :eof

:flash-lazy
echo Installing Lazyflasher...
adb sideload .\data\lazyflasher.zip
goto :eof

:flash-cam2api
echo Installing Camera2 API Enabler...
adb sideload .\data\cam2api-enabler.zip
>nul 2>&1 timeout /t 5 /nobreak
echo Patching build.prop script...
adb push .\data\mount-system.sh /tmp/mount-system.sh
adb push .\data\unmount-system.sh /tmp/unmount-system.sh

:mount-system
echo Mounting /system...
>nul 2>&1 adb shell "/sbin/busybox /tmp/mount-system.sh"
>nul 2>&1 adb shell "/sbin/sh /tmp/mount-system.sh"
for %%s in (/system /system/system) do ( >nul 2>&1 adb pull %%s/build.prop .\tmp\build.prop )
if not exist .\tmp\build.prop (
   echo %errorp%  /system not yet mounted.
   choice /c yn /n /m "Try again? [Y/N] "
   if errorlevel 2 (
      call :unmount-system
      set "no_mount=1"
      call :end2
      goto :eof
   )
   goto mount-system
)
del /q .\tmp\build.prop

:write-prop
echo Writing /system/build.prop...
>nul 2>&1 adb shell "setprop persist.vendor.camera.HAL3.enabled 1"
>nul 2>&1 adb shell "setprop persist.camera.HAL3.enabled 1"
>nul 2>&1 adb shell "setprop persist.camera.eis.enable 1"
for %%s in (/system /system/system) do (
   echo Patching addon.d Camera2 API...
   >nul 2>&1 adb shell "mkdir %%s/addon.d"
   adb push .\data\cam2api_addon.sh %%s/addon.d/34-camera.sh
   >nul 2>&1 adb shell "chmod -R 0755 %%s/addon.d"
   >nul 2>&1 adb shell "chmod -R 0755 %%s/addon.d/34-camera.sh"
)

:unmount-system
echo Unmounting /system...
>nul 2>&1 adb shell "/sbin/busybox /tmp/unmount-system.sh"
>nul 2>&1 adb shell "/sbin/sh /tmp/unmount-system.sh"
goto :eof

:flash-root
@echo off
break off
cls
echo.
echo INSTALL ROOT
echo อออออออออออออ
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
if [%choice%] == [Q]  (
   set "root_exit=1"
   goto :eof
)
if [%choice%] == [q]  (
   set "root_exit=1"
   goto :eof
)
call :check-sideload
if [%choice%] == [2]  (
   set "rootsel=Magisk"
   set "rootzip=.\data\magisk.zip"
)
if [%choice%] == [1]  (
   set "rootsel=SuperSU"
   set "rootzip=.\data\supersu.zip"
)
echo Installing %rootsel%...
>nul 2>&1 adb sideload %rootzip%
call :end2
goto :eof

:manualcam
echo Installing Manual Camera Compatibility Test APK...
adb install .\data\manualcamera.apk 2>&1 | findstr /r /c:"Success\>" || (
   echo %errorp%  APK install failed.
)
goto :eof

:reboot-systemdevices
echo Rebooting...
if [%reboot_fastboot%] == [1] (
   fastboot %* reboot >nul || (
      echo %errorp%  Cannot reboot.
   )
)
if [%reboot_adb%] == [1] (
   adb reboot || (
      echo %errorp%  Cannot reboot.
   )
)
goto :eof

:reboot-bootloader
echo Rebooting to bootloader...
if [%bootloader_adb%] == [1] (
   adb reboot bootloader || (
      echo %errorp%  Cannot reboot to bootloader.
   )
)
if [%bootloader_fastboot%] == [1] (
   fastboot %* reboot bootloader >nul || (
      echo %errorp%  Cannot reboot to bootloader.
   )
)
goto :eof

:reboot-recovery
if [%recovery_fastboot%] == [1] (
   if not defined recoveryimg set "recoveryimg=.\recovery\ofox.img"
   echo Booting to recovery...
   fastboot %* boot %recoveryimg% || (
      echo %errorp%  Cannot boot to recovery.
      set "error=1"
      call :end2
      goto :eof
   )
   echo %infop%  Download 'recovery' to 'boot' success.
)
if [%recovery_adb%] == [1] (
   echo Rebooting to recovery...
   adb reboot recovery || (
      echo %errorp%  Cannot reboot to recovery.
   )
)
goto :eof


:end1
echo Exiting from program...
echo Closing ADB service...
>nul 2>&1 adb kill-server
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
:: Facilities of this program, include^:
::   1.  Check the bootloader
::   2.  Flash TWRP
::   3.  Flash LazyFlasher
::   4.  Flash Camera2 API
::   5.  Flash Root Access
::
:: This program is only for those who have a Xiaomi Redmi Note 5 Global^/Pro
:: phone ^(codename^: Whyred^)
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
