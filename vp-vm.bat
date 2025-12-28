@echo off
setlocal enabledelayedexpansion

REM ANSI color codes
set "red=[91m"
set "green=[92m"
set "yellow=[93m"
set "cyan=[1;96m"
set "reset=[0m"

REM Check command (%1)
if "%~1"=="" goto help
if /i "%~1"=="update" goto update
if /i "%~1"=="upgrade" goto upgrade
if /i "%~1"=="list-upgradable" goto list_upgradable
if /i "%~1"=="--version" goto version
if /i "%~1"=="--help" goto help

:invalid
echo %red%Command '%~1' not recognised.%reset%
goto help
exit /b 1

:update
call "%INSTALL_DIR%\update-versions.bat"
exit /b !errorlevel!

:upgrade
call "%INSTALL_DIR%\upgrade.bat"
exit /b !errorlevel!

:list_upgradable
call "%INSTALL_DIR%\list-upgradable.bat"
exit /b !errorlevel!

:version
echo 0.6.0
exit /b 0

:help
echo %cyan%=============================================%reset%
echo %cyan%Vocabulary Plus Version Manager: Help (0.6.0)%reset%
echo %cyan%=============================================%reset%
echo Usage: vp-vm [command]
echo.
echo Commands:
echo    update            Update the version lists
echo    upgrade           Upgrade Vocabulary Plus and vp-vm to the latest version
echo    list-upgradable   Show upgradable packages
echo    --version         Show the installed version of Vocabulary Plus Version Manager
echo    --help            Show this help message and exit
exit /b 0
