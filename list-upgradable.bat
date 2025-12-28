@echo off
setlocal enabledelayedexpansion

REM ANSI colour codes
set "red=[91m"
set "green=[92m"
set "yellow=[93m"
set "blue=[94m"
set "purple=[35m"
set "reset=[0m"

timeout /t 0 /nobreak
echo %yellow%Listing...%reset%
timeout /t 0 /nobreak

REM Extract versions from downloaded files
for /f "delims=" %%A in ('type "!INSTALL_DIR!\versions\vp\latest.txt"') do set "VP_VERSION=%%A"
timeout /t 0 /nobreak

for /f "delims=" %%A in ('type "!INSTALL_DIR!\versions\vp-vm\latest.txt"') do set "VP_VM_VERSION=%%A"
timeout /t 0 /nobreak

REM Get currently installed versions
for /f "delims=" %%A in ('type "!INSTALL_DIR!\versions\vp\current.txt"') do set "CURRENT_VP_VERSION=%%A"
timeout /t 0 /nobreak

for /f "delims=" %%A in ('type "!INSTALL_DIR!\versions\vp-vm\current.txt"') do set "CURRENT_VP_VM_VERSION=%%A"

set "VP_NEEDS_UPDATE=false"
if not "!VP_VERSION!"=="!CURRENT_VP_VERSION!" set "VP_NEEDS_UPDATE=true"

set "VP_VM_NEEDS_UPDATE=false"
if not "!VP_VM_VERSION!"=="!CURRENT_VP_VM_VERSION!" set "VP_VM_NEEDS_UPDATE=true"

REM Print list
if "!VP_NEEDS_UPDATE!"=="true" (
    echo %blue%Vocabulary Plus%reset% (!red!!CURRENT_VP_VERSION!!reset! -^> !green!!VP_VERSION!!reset!)
)
timeout /t 0 /nobreak

if "!VP_VM_NEEDS_UPDATE!"=="true" (
    echo %blue%Vocabulary Plus Version Manager%reset% (!red!!CURRENT_VP_VM_VERSION!!reset! -^> !green!!VP_VM_VERSION!!reset!)
)

if "!VP_NEEDS_UPDATE!"=="true" (
    echo %purple%Run 'vp-vm upgrade' to upgrade all packages.%reset%
) else if "!VP_VM_NEEDS_UPDATE!"=="true" (
    echo %purple%Run 'vp-vm upgrade' to upgrade all packages.%reset%
)

timeout /t 0 /nobreak

exit /b 0
