@echo off
setlocal enabledelayedexpansion

REM ANSI colour codes
set "red=[91m"
set "green=[92m"
set "yellow=[93m"
set "cyan=[1;96m"
set "reset=[0m"

REM Abort if INSTALL_DIR is empty
if "!INSTALL_DIR!"=="" (
    echo %red%ERROR: INSTALL_DIR is not set.%reset%
    exit /b 1
)

REM Disable stdout if %1 is -s or --silent
set "SILENT=0"
if /i "%~1"=="-s" set "SILENT=1"
if /i "%~1"=="--silent" set "SILENT=1"

if %SILENT% equ 1 (
    REM Redirect output to nul for silent mode
    call :main > nul 2>&1
) else (
    call :main
)

exit /b !errorlevel!

:main

echo %cyan%====================================================%reset%
echo %cyan%Vocabulary Plus Version Manager: Uninstaller (0.7.0)%reset%
echo %cyan%====================================================%reset%
timeout /t 1 /nobreak

cd /d "!INSTALL_DIR!"

REM Remove the VocabularyPlus/vm directory ("!INSTALL_DIR!")
echo.
echo %yellow%Removing vm directory...%reset%
REM If the working directory is about to be removed, change to the parent directory
if "!cd!"=="!INSTALL_DIR!" (
    cd ..
)
rmdir /s /q "!INSTALL_DIR!" 2>nul
timeout /t 0 /nobreak
echo %green%Directory removed%reset%
timeout /t 0 /nobreak

REM Remove the control script (vp-vm)
echo.
echo %yellow%Removing control script...%reset%
if exist "%USERPROFILE%\bin\vp-vm.bat" (
    del "%USERPROFILE%\bin\vp-vm.bat" 2>nul
)
timeout /t 0 /nobreak
echo %green%Control script removed.%reset%
timeout /t 0 /nobreak

REM Final message
echo.
echo %green%Vocabulary Plus Version Manager 0.7.0 successfully uninstalled.%reset%
echo %yellow%If you found any errors in Vocabulary Plus Version Manager, please report them at https://github.com/46Dimensions/vp-vm/issues%reset%

exit /b 0
