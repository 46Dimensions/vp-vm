#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[91m"
green="\033[92m"
yellow="\033[93m"
boldcyan="\033[1;96m"
cyan="\033[96m"
reset="\033[0m"

echo "${boldcyan}=========================================================${reset}"
echo "${boldcyan}Vocabulary Plus Version Manager: Package Upgrader (0.5.0)${reset}"
echo "${boldcyan}=========================================================${reset}"
sleep 1

echo "${yellow}Reading package lists...${reset}"
# Get the Vocabulary Plus version to upgrade to
VP_CURRENT=$(cat "$INSTALL_DIR/versions/vp/current.txt")
VP_LATEST=$(cat "$INSTALL_DIR/versions/vp/latest.txt")
# Set the Vocabulary Plus upgrade flag
if [ "$VP_CURRENT" != "$VP_LATEST" ]; then
    UPGRADE_VP=true
else
    UPGRADE_VP=false
fi

# Get the Vocabulary Plus Version Manager version to upgrade to
VM_CURRENT=$(cat "$INSTALL_DIR/versions/vp-vm/current.txt")
VM_LATEST=$(cat "$INSTALL_DIR/versions/vp-vm/latest.txt")
# Set the Vocabulary Plus Version Manager upgrade flag
if [ "$VM_CURRENT" != "$VM_LATEST" ]; then
    UPGRADE_VM=true
else
    UPGRADE_VM=false
fi
sleep 0.5
echo "${yellow}Calculating upgrade...${reset}"



# Upgrade current Vocabulary Plus if needed
if [ "$UPGRADE_VP" = true ]; then
    echo ""
    echo "${yellow}Upgrading Vocabulary Plus...${reset}"
    sleep 1
    echo "${yellow}Backing up vocabulary files...${reset}"
    # Move the JSON files and VM into a temporary location
    cd "$INSTALL_DIR"
    cd .. # Move into VocabularyPlus parent directory
    cd .. # Move into VocabularyPlus's parent directory
    mkdir -p VocabularyPlusTemp
    mv VocabularyPlus/JSON VocabularyPlusTemp/JSON || { echo "${red}WARNING: ${PWD}/VocabularyPlus/JSON not found so not backed up${reset}"; } # This problem is not critical; VocabularyPlus/JSON is not created until main.py is run
    mv VocabularyPlus/vm VocabularyPlusTemp/vm || { echo "${red}ERROR: ${PWD}/VocabularyPlus/vm not found so not backed up${reset}"; exit 1; }
    echo "${green}Vocabulary files backed up.${reset}"
    sleep 0.5

    echo ""
    echo "${yellow}Uninstalling current Vocabulary Plus version...${reset}"
    # Run the Vocabulary Plus uninstaller
    sh VocabularyPlus/uninstall -s
    # Abort if uninstallation fails
    if [ "$?" != 0 ]; then
        exit 1
    fi
    echo "${green}Current Vocabulary Plus version uninstalled.${reset}"
    sleep 0.5

    echo ""
    # Install the latest version
    echo "${yellow}Installing latest Vocabulary Plus version...${reset}"
    curl -fsSL https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/main/install.sh -o install.sh
    sh install.sh -s
    # Abort if installation fails
    if [ $? != 0 ]; then
        echo "Installation failed."
        rm install.sh
        exit 1
    fi
    rm install.sh
    sleep 0.5

    echo ""
    # Move the JSON files and VM back into VocabularyPlus directory
    if [ -d "VocabularyPlus/JSON" ]; then
        rm -rf VocabularyPlus/JSON
    fi

    if [ -d "VocabularyPlus/vm" ]; then
        rm -rf VocabularyPlus/vm
    fi
    mv "VocabularyPlusTemp/JSON" "VocabularyPlus/JSON" || { echo "${red}WARNING: ${PWD}/VocabularyPlusTemp/JSON not found so not backed up${reset}"; } # This problem is not critical; VocabularyPlus/JSON is not created until main.py is run
    mv "VocabularyPlusTemp/vm" "VocabularyPlus/vm" || { echo "${red}ERROR: ${PWD}/VocabularyPlusTemp/vm not found so not backed up${reset}"; exit 1; }
    rm -rf VocabularyPlusTemp
    # Set the current version to the latest version
    echo $VP_LATEST > "$INSTALL_DIR/versions/vp/current.txt"
    echo "${green}Latest Vocabulary Plus version installed.${reset}"
fi

# Upgrade Vocabulary Plus Version Manager if needed
if [ "$UPGRADE_VM" = true ]; then
    echo ""
    echo "${yellow}Upgrading Vocabulary Plus Version Manager...${reset}"
    sleep 1
    echo "${yellow}Backing up version files...${reset}"
    # Move the Vocabulary Plus version files into a temporary location
    cd "$INSTALL_DIR"
    cd .. # Move into VocabularyPlus parent directory
    mkdir -p vm-temp
    mv "$INSTALL_DIR/versions/vp" "vm-temp/vp"
    echo "${green}Version files backed up.${reset}"
    sleep 0.5

    echo ""
    echo "${yellow}Uninstalling current VP VM...${reset}"
    # Run the VP VM uninstaller
    sh vm/uninstall.sh -s
    # Abort if uninstallation fails
    if [ "$?" != 0 ]; then
        echo "${red}Uninstallation failed.${reset}"
        exit 1
    fi
    echo "${green}Current VP VM uninstalled.${reset}"
    echo ""
    sleep 0.5

    echo ""
    # Install the latest VP VM version
    echo "${yellow}Installing latest VP VM...${reset}"
    curl -fsSL https://raw.githubusercontent.com/46Dimensions/vp-vm/main/install-vm.sh -o install-vm.sh
    sh install-vm.sh $INSTALL_DIR --silent
    rm install-vm.sh
    # Move the Vocabulary Plus version files back into the versions directory
    mv vm-temp/vp "$INSTALL_DIR/versions"
    rm -rf vm-temp
    # Set the current version to the latest version
    echo $VM_LATEST > "$INSTALL_DIR/versions/vp-vm/current.txt"
    echo "${green}Latest Vocabulary Plus Version Manager installed.${reset}"
fi
sleep 2

echo ""
echo "${cyan}Upgrade Summary${reset}"
echo "${cyan}---------------${reset}"
sleep 0.25
if [ "$UPGRADE_VP" = true ]; then
    echo "Vocabulary Plus ${red}$VP_CURRENT${reset} -> ${green}$VP_LATEST${reset}"
fi
sleep 0.25
if [ "$UPGRADE_VM" = true ]; then
    echo "Vocabulary Plus Version Manager ${red}$VM_CURRENT${reset} -> ${green}$VM_LATEST${reset}"
fi
if [ "$UPGRADE_VP" = false ] && [ "$UPGRADE_VM" = false ]; then
    echo "0 packages upgraded."
fi