@echo off
setlocal enabledelayedexpansion

REM ANSI color codes
set "red=[91m"
set "green=[92m"
set "yellow=[93m"
set "cyan=[1;96m"
set "reset=[0m"

REM Set install directory
if "%~1"=="" (
    echo Usage: %0 ^<install-directory^> [-s^|--silent]
    exit /b 1
)
set "INSTALL_DIR=%~1"

REM Disable stdout if %2 is -s or --silent
set "SILENT=0"
if /i "%~2"=="-s" set "SILENT=1"
if /i "%~2"=="--silent" set "SILENT=1"

if %SILENT% equ 1 (
    REM Redirect output to nul for silent mode
    call :main > nul 2>&1
) else (
    call :main
)
exit /b !errorlevel!

:main
echo %cyan%=======================================================%reset%
echo %cyan%Vocabulary Plus Version Manager: Windows Installer (1.0.0)%reset%
echo %cyan%=======================================================%reset%
echo.

REM Check that curl exists
where curl >nul 2>&1
if errorlevel 1 (
    echo %red%Error: curl is not installed. Please install curl and try again.%reset%
    exit /b 1
)

REM Create installation directory if it doesn't exist
echo %yellow%Creating installation directory (!INSTALL_DIR!)...%reset%
if not exist "!INSTALL_DIR!" mkdir "!INSTALL_DIR!"
echo %green%Installation directory created.%reset%
echo.

REM Create the directories for version files
echo %yellow%Creating versions directory...%reset%
if not exist "!INSTALL_DIR!\versions" mkdir "!INSTALL_DIR!\versions"
if not exist "!INSTALL_DIR!\versions\vp" mkdir "!INSTALL_DIR!\versions\vp"
if not exist "!INSTALL_DIR!\versions\vp-vm" mkdir "!INSTALL_DIR!\versions\vp-vm"
echo %green%Versions directory created.%reset%
echo.

REM Write vp-vm current version file
echo %yellow%Setting up current version file...%reset%
echo 1.0.0 > "!INSTALL_DIR!\versions\vp-vm\current.txt"
echo %green%Current version file set up.%reset%
echo.

REM Download the scripts
echo %yellow%Downloading scripts...%reset%
set "BASE_URL=https://raw.githubusercontent.com/46Dimensions/vp-vm/main"

curl -fsSL "!BASE_URL!/update-versions.sh" -o "!INSTALL_DIR!\update-versions.sh"
if errorlevel 1 (
    echo %red%Failed to download version updater script.%reset%
    exit /b 1
)

curl -fsSL "!BASE_URL!/upgrade.sh" -o "!INSTALL_DIR!\upgrade.sh"
if errorlevel 1 (
    echo %red%Failed to download upgrader script.%reset%
    exit /b 1
)

curl -fsSL "!BASE_URL!/uninstall.sh" -o "!INSTALL_DIR!\uninstall.sh"
if errorlevel 1 (
    echo %red%Failed to download uninstaller.%reset%
    exit /b 1
)

curl -fsSL "!BASE_URL!/list-upgradable.sh" -o "!INSTALL_DIR!\list-upgradable.sh"
if errorlevel 1 (
    echo %red%Failed to download upgradable package lister.%reset%
    exit /b 1
)

curl -fsSL "!BASE_URL!/vp-vm.sh" -o "!INSTALL_DIR!\vp-vm.sh"
if errorlevel 1 (
    echo %red%Failed to download main script.%reset%
    exit /b 1
)

echo %green%Scripts downloaded successfully.%reset%
echo.

REM Note: Windows batch doesn't have the same Unix-like permission model,
REM so we skip chmod. The .bat files are ready to use.
echo %yellow%Configuring scripts...%reset%

REM Convert shell scripts to batch scripts
powershell -Command "& {(Get-Content '!INSTALL_DIR!\update-versions.sh') -replace '@echo off', '' -replace 'setlocal enabledelayedexpansion', '' | Set-Content '!INSTALL_DIR!\update-versions.bat'}"
powershell -Command "& {(Get-Content '!INSTALL_DIR!\upgrade.sh') -replace '@echo off', '' -replace 'setlocal enabledelayedexpansion', '' | Set-Content '!INSTALL_DIR!\upgrade.bat'}"
powershell -Command "& {(Get-Content '!INSTALL_DIR!\uninstall.sh') -replace '@echo off', '' -replace 'setlocal enabledelayedexpansion', '' | Set-Content '!INSTALL_DIR!\uninstall.bat'}"
powershell -Command "& {(Get-Content '!INSTALL_DIR!\list-upgradable.sh') -replace '@echo off', '' -replace 'setlocal enabledelayedexpansion', '' | Set-Content '!INSTALL_DIR!\list-upgradable.bat'}"

REM Note: For Windows, the main script would typically be in a bin directory or added to PATH
if not exist "%USERPROFILE%\bin" mkdir "%USERPROFILE%\bin"
powershell -Command "& {(Get-Content '!INSTALL_DIR!\vp-vm.sh') -replace '@echo off', '' -replace 'setlocal enabledelayedexpansion', '' | Set-Content '%USERPROFILE%\bin\vp-vm.bat'}"

echo %green%Scripts configured successfully.%reset%
echo.

exit /b 0
