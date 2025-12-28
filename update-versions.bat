@echo off
setlocal enabledelayedexpansion

REM ANSI color codes
set "red=[91m"
set "green=[92m"
set "yellow=[93m"
set "cyan=[1;96m"
set "blue=[94m"
set "purple=[35m"
set "reset=[0m"

REM Header
echo %cyan%========================================================%reset%
echo %cyan%Vocabulary Plus Version Manager: Version Updater (0.6.0)%reset%
echo %cyan%========================================================%reset%

REM Function to get the contents of a version file
:extract_version
setlocal enabledelayedexpansion
set "file_path=%~1"
echo %purple%READ: !file_path!%reset% >&2
if exist "!file_path!" (
    for /f "delims=" %%A in ('type "!file_path!"') do (
        set "version=%%A"
    )
    echo !version!
) else (
    echo %red%Error: File '!file_path!' not found.%reset% >&2
    exit /b 1
)
endlocal & exit /b 0

REM Get most recent versions of Vocabulary Plus and Vocabulary Plus Version Manager
REM Save them to "%INSTALL_DIR%\versions"
set "VP_URL=https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/1.3.0_stable/VERSION.txt"
echo %blue%GET: !VP_URL! %reset%
curl -fsSL "!VP_URL!" -o "!INSTALL_DIR!\versions\vp\latest.txt"
if errorlevel 1 (
    echo %red% Error getting latest version of Vocabulary Plus.%reset%
    exit /b 1
)

set "VP_VM_URL=https://raw.githubusercontent.com/46Dimensions/vp-vm/main/VERSION.txt"
echo %blue%GET: !VP_VM_URL! %reset%
curl -fsSL "!VP_VM_URL!" -o "!INSTALL_DIR!\versions\vp-vm\latest.txt"
if errorlevel 1 (
    echo %red% Error getting latest version of Vocabulary Plus Version Manager.%reset%
    exit /b 1
)

timeout /t 1 /nobreak

REM Extract versions from downloaded files
for /f "delims=" %%A in ('type "!INSTALL_DIR!\versions\vp\latest.txt"') do set "VP_VERSION=%%A"
timeout /t 0 /nobreak

for /f "delims=" %%A in ('type "!INSTALL_DIR!\versions\vp-vm\latest.txt"') do set "VP_VM_VERSION=%%A"
timeout /t 0 /nobreak

REM Get currently installed versions
for /f "delims=" %%A in ('type "!INSTALL_DIR!\versions\vp\current.txt"') do set "CURRENT_VP_VERSION=%%A"
timeout /t 0 /nobreak

for /f "delims=" %%A in ('type "!INSTALL_DIR!\versions\vp-vm\current.txt"') do set "CURRENT_VP_VM_VERSION=%%A"
timeout /t 1 /nobreak

echo.
echo %yellow%Checking for updates...%reset%

if "!VP_VERSION!"=="!CURRENT_VP_VERSION!" (
    set "VP_NEEDS_UPDATE=false"
) else (
    set "VP_NEEDS_UPDATE=true"
)

if "!VP_VM_VERSION!"=="!CURRENT_VP_VM_VERSION!" (
    set "VP_VM_NEEDS_UPDATE=false"
) else (
    set "VP_VM_NEEDS_UPDATE=true"
)

set "UPDATABLE_PACKAGES=0"
if "!VP_NEEDS_UPDATE!"=="true" set /a "UPDATABLE_PACKAGES+=1"
if "!VP_VM_NEEDS_UPDATE!"=="true" set /a "UPDATABLE_PACKAGES+=1"

timeout /t 1 /nobreak

REM Print summary
if %UPDATABLE_PACKAGES% equ 0 (
    echo %green%All packages are up to date.%reset%
) else (
    echo %blue%!UPDATABLE_PACKAGES! package(s) can be updated.%reset%
    echo %purple%Use 'vp-vm list-upgradable' to see them.%reset%
)

exit /b 0
