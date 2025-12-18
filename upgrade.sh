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
echo "${boldcyan}Vocabulary Plus Version Manager: Package Upgrader (0.4.1)${reset}"
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
    echo "${yellow}Upgrading Vocabulary Plus...${reset}"
    sleep 1
    echo "${yellow}Uninstalling current Vocabulary Plus version...${reset}"
    # Move the JSON files and VM into a temporary location
    cd "$INSTALL_DIR"
    cd .. # Move into VocabularyPlus parent directory
    cd .. # Move into VocabularyPlus's parent directory
    mkdir -p VocabularyPlusTemp
    mv VocabularyPlus/JSON VocabularyPlusTemp/JSON
    mv VocabularyPlus/vm VocabularyPlusTemp/vm
    # Run the Vocabulary Plus uninstaller
    sh VocabularyPlus/uninstall -s
    # Abort if uninstallation fails
    if [ "$?" != 0 ]; then
        exit 1
    fi
    echo "${green}Current Vocabulary Plus version uninstalled.${reset}"
    echo ""
    # Install the latest version
    echo "${yellow}Installing latest Vocabulary Plus version...${reset}"
    curl -fsSL https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/main/install.sh -o install.sh
    sh install.sh
    rm install.sh
    # Move the JSON files and VM back into VocabularyPlus directory
    if [ -d "VocabularyPlus/JSON" ]; then
        rm -rf VocabularyPlus/JSON
    fi

    if [ -d "VocabularyPlus/vm" ]; then
        rm -rf VocabularyPlus/vm
    fi
    mv "VocabularyPlusTemp/JSON" "VocabularyPlus/JSON"
    mv "VocabularyPlusTemp/vm" "VocabularyPlus/vm"
    rm -rf VocabularyPlusTemp
    # Set the current version to the latest version
    echo $VP_LATEST > "$INSTALL_DIR/versions/vp/current.txt"
    echo "${green}Latest Vocabulary Plus version installed.${reset}"
    echo ""
fi

# Upgrade Vocabulary Plus Version Manager if needed
if [ "$UPGRADE_VM" = true ]; then
    echo "${yellow}Upgrading Vocabulary Plus Version Manager...${reset}"
    sleep 1
    # Move the Vocabulary Plus version files into a temporary location
    cd "$INSTALL_DIR"
    cd .. # Move into VocabularyPlus parent directory
    mkdir -p vm-temp
    mv "$INSTALL_DIR/versions/vp" "vm-temp/vp"
    # Run the VP VM uninstaller
    sh vm/uninstall.sh -s
    # Abort if uninstallation fails
    if [ "$?" != 0 ]; then
        exit 1
    fi
    echo "${green}Current Vocabulary Plus Version Manager uninstalled.${reset}"
    echo ""
    # Install the latest VP VM version
    echo "${yellow}Installing latest Vocabulary Plus Version Manager...${reset}"
    curl -fsSL https://raw.githubusercontent.com/46Dimensions/vp-vm/main/install-vm.sh -o install.sh
    sh install.sh
    rm install.sh
    # Move the Vocabulary Plus version files back into the versions directory
    mv vm-temp/vp "$INSTALL_DIR/versions/vp"
    rm -rf vm-temp
    # Set the current version to the latest version
    echo $VM_LATEST > "$INSTALL_DIR/versions/vp-vm/current.txt"
    echo "${green}Latest Vocabulary Plus Version Manager installed.${reset}"
    echo ""
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