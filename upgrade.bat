@echo off
setlocal enabledelayedexpansion

REM ANSI colour codes
set "red=[91m"
set "green=[92m"
set "yellow=[93m"
set "boldcyan=[1;96m"
set "cyan=[96m"
set "reset=[0m"

echo %boldcyan%=========================================================%reset%
echo %boldcyan%Vocabulary Plus Version Manager: Package Upgrader (1.0.0)%reset%
echo %boldcyan%=========================================================%reset%
timeout /t 1 /nobreak

echo %yellow%Reading package lists...%reset%

REM Get the Vocabulary Plus version to upgrade to
for /f "delims=" %%A in ('type "!INSTALL_DIR!\versions\vp\current.txt"') do set "VP_CURRENT=%%A"
for /f "delims=" %%A in ('type "!INSTALL_DIR!\versions\vp\latest.txt"') do set "VP_LATEST=%%A"

REM Set the Vocabulary Plus upgrade flag
if "!VP_CURRENT!"=="!VP_LATEST!" (
    set "UPGRADE_VP=false"
) else (
    set "UPGRADE_VP=true"
)

REM Get the Vocabulary Plus Version Manager version to upgrade to
for /f "delims=" %%A in ('type "!INSTALL_DIR!\versions\vp-vm\current.txt"') do set "VM_CURRENT=%%A"
for /f "delims=" %%A in ('type "!INSTALL_DIR!\versions\vp-vm\latest.txt"') do set "VM_LATEST=%%A"

REM Set the Vocabulary Plus Version Manager upgrade flag
if "!VM_CURRENT!"=="!VM_LATEST!" (
    set "UPGRADE_VM=false"
) else (
    set "UPGRADE_VM=true"
)

timeout /t 0 /nobreak
echo %yellow%Calculating upgrade...%reset%

REM Upgrade current Vocabulary Plus if needed
if "!UPGRADE_VP!"=="true" (
    echo.
    echo %yellow%Upgrading Vocabulary Plus...%reset%
    timeout /t 1 /nobreak
    echo %yellow%Backing up vocabulary files...%reset%
    
    REM Move the JSON files and VM into a temporary location
    cd /d "!INSTALL_DIR!"
    cd ..
    cd ..
    
    if not exist "VocabularyPlusTemp" mkdir "VocabularyPlusTemp"
    
    REM Backup JSON if it exists
    if exist "VocabularyPlus\JSON" (
        move "VocabularyPlus\JSON" "VocabularyPlusTemp\JSON" >nul
    ) else (
        echo %red%WARNING: VocabularyPlus\JSON not found so not backed up%reset%
    )
    
    REM Backup vm
    if exist "VocabularyPlus\vm" (
        move "VocabularyPlus\vm" "VocabularyPlusTemp\vm" >nul
    ) else (
        echo %red%ERROR: VocabularyPlus\vm not found so not backed up%reset%
        exit /b 1
    )
    
    echo %green%Vocabulary files backed up.%reset%
    timeout /t 0 /nobreak

    echo.
    echo %yellow%Uninstalling current Vocabulary Plus version...%reset%
    
    REM Run the Vocabulary Plus uninstaller
    if exist "VocabularyPlus\uninstall.bat" (
        call "VocabularyPlus\uninstall.bat" -s
    ) else (
        echo %red%Error: Vocabulary Plus uninstaller not found%reset%
        exit /b 1
    )
    
    echo %green%Current Vocabulary Plus version uninstalled.%reset%
    timeout /t 0 /nobreak

    echo.
    echo %yellow%Installing latest Vocabulary Plus version...%reset%
    
    curl -fsSL https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/1.3.0_stable/install.sh -o install.sh
    if errorlevel 1 (
        echo %red%Failed to download Vocabulary Plus installer%reset%
        exit /b 1
    )
    
    REM Note: Windows would need a .bat version of the installer
    REM For now, we'll try to use the script through bash if available
    bash install.sh -s
    if errorlevel 1 (
        echo %red%Installation failed.%reset%
        del install.sh
        exit /b 1
    )
    del install.sh
    timeout /t 0 /nobreak

    echo.
    
    REM Move the JSON files and VM back into VocabularyPlus directory
    if exist "VocabularyPlus\JSON" rmdir /s /q "VocabularyPlus\JSON" 2>nul
    if exist "VocabularyPlus\vm" rmdir /s /q "VocabularyPlus\vm" 2>nul
    
    if exist "VocabularyPlusTemp\JSON" (
        move "VocabularyPlusTemp\JSON" "VocabularyPlus\JSON" >nul
    ) else (
        echo %red%WARNING: VocabularyPlusTemp\JSON not found%reset%
    )
    
    if exist "VocabularyPlusTemp\vm" (
        move "VocabularyPlusTemp\vm" "VocabularyPlus\vm" >nul
    ) else (
        echo %red%ERROR: VocabularyPlusTemp\vm not found%reset%
        exit /b 1
    )
    
    rmdir /s /q "VocabularyPlusTemp" 2>nul
    
    REM Set the current version to the latest version
    echo !VP_LATEST! > "!INSTALL_DIR!\versions\vp\current.txt"
    echo %green%Latest Vocabulary Plus version installed.%reset%
)

REM Upgrade Vocabulary Plus Version Manager if needed
if "!UPGRADE_VM!"=="true" (
    echo.
    echo %yellow%Upgrading Vocabulary Plus Version Manager...%reset%
    timeout /t 1 /nobreak
    echo %yellow%Backing up version files...%reset%
    
    cd /d "!INSTALL_DIR!"
    cd ..
    
    if not exist "vm-temp" mkdir "vm-temp"
    move "!INSTALL_DIR!\versions\vp" "vm-temp\vp" >nul
    
    echo %green%Version files backed up.%reset%
    timeout /t 0 /nobreak

    echo.
    echo %yellow%Uninstalling current VP VM...%reset%
    
    REM Run the VP VM uninstaller
    if exist "vm\uninstall.bat" (
        call "vm\uninstall.bat" -s
    ) else (
        echo %red%Error: VP VM uninstaller not found%reset%
        exit /b 1
    )
    
    echo %green%Current VP VM uninstalled.%reset%
    echo.
    timeout /t 0 /nobreak

    echo.
    echo %yellow%Installing latest VP VM...%reset%
    
    curl -fsSL https://raw.githubusercontent.com/46Dimensions/vp-vm/main/install-vm.bat -o install-vm.bat
    if errorlevel 1 (
        echo %red%Failed to download VP VM installer%reset%
        exit /b 1
    )
    
    call "install-vm.bat" "!INSTALL_DIR!" --silent
    del install-vm.bat
    
    move "vm-temp\vp" "!INSTALL_DIR!\versions" >nul
    rmdir /s /q "vm-temp" 2>nul
    
    REM Set the current version to the latest version
    echo !VM_LATEST! > "!INSTALL_DIR!\versions\vp-vm\current.txt"
    echo %green%Latest Vocabulary Plus Version Manager installed.%reset%
)

timeout /t 2 /nobreak

echo.
echo %cyan%Upgrade Summary%reset%
echo %cyan%---------------%reset%
timeout /t 0 /nobreak

if "!UPGRADE_VP!"=="true" (
    echo Vocabulary Plus %red%!VP_CURRENT!%reset% -^> %green%!VP_LATEST!%reset%
)

timeout /t 0 /nobreak

if "!UPGRADE_VM!"=="true" (
    echo Vocabulary Plus Version Manager %red%!VM_CURRENT!%reset% -^> %green%!VM_LATEST!%reset%
)

if "!UPGRADE_VP!"=="false" if "!UPGRADE_VM!"=="false" (
    echo 0 packages upgraded.
)

exit /b 0
