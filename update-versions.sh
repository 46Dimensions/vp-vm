#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
reset="\033[0m"

# Header
echo "${green}========================================================${reset}"
echo "${green}Vocabulary Plus Version Manager: Version Updater (0.2.0)${reset}"
echo "${green}========================================================${reset}"

# Function to get the contents of a version file
extract_version() {
    local file_path="$1"
    echo "${yellow}READ: ${file_path}${reset}"
    if [ -f "$file_path" ]; then
        CONTENTS=$(cat "$file_path")
    else
        echo "${red}Error: File '$file_path' not found.${reset}"
        exit 1
    fi
    return "$CONTENTS" 
}

# Get most recent versions of Vocabulary Plus and Vocabulary Plus Version Manager
# Save them to $INSTALL_DIR/versions
VP_URL=https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/vp-vm/version.txt
echo "${yellow}GET: ${VP_URL} ${reset}"
curl -fsSL $VP_URL -o $INSTALL_DIR/versions/vp/latest.txt || { echo "${red} Error getting latest version of Vocabulary Plus.${reset}"; exit 1; }
VP_VM_URL=https://raw.githubusercontent.com/46Dimensions/vp-vm/main/version.txt
echo "${yellow}GET: ${VP-VM_URL} ${reset}"
curl -fsSL $VP_VM_URL -o $INSTALL_DIR/versions/vp-vm/latest.txt || { echo "${red} Error getting latest version of Vocabulary Plus Version Manager.${reset}"; exit 1; }

# Extract versions from downloaded files
VP_VERSION=$(extract_version "$INSTALL_DIR/versions/vp/latest.txt")
VP_VM_VERSION=$(extract_version "$INSTALL_DIR/versions/vp-vm/latest.txt")

# Get currently installed versions
CURRENT_VP_VERSION=$(extract_version "$INSTALL_DIR/versions/vp/current.txt")
CURRENT_VP_VM_VERSION=$(extract_version "$INSTALL_DIR/versions/vp-vm/current.txt")

if [ "$VP_VERSION" != "$CURRENT_VP_VERSION" ]; then
    VP_NEEDS_UPDATE=true
else
    VP_NEEDS_UPDATE=false
fi

if [ "$VP_VM_VERSION" != "$CURRENT_VP_VM_VERSION" ]; then
    VP_VM_NEEDS_UPDATE=true
else
    VP_VM_NEEDS_UPDATE=false
fi

# Get number of updatable packages
if [ "$VP_NEEDS_UPDATE" = true ]; then
    UPDATABLE_PACKAGES="1"
fi

if [ "$VP_VM_NEEDS_UPDATE" = true ]; then
    if [ "$UPDATABLE_PACKAGES" = "1" ]; then
        UPDATABLE_PACKAGES="2"
    else
        UPDATABLE_PACKAGES="1"
    fi
fi

# Print summary
if [ -n "$UPDATABLE_PACKAGES" ]; then
    echo "${green}All packages are up to date.${reset}"
    exit 0
else
    echo "${yellow}${UPDATABLE_PACKAGES} package(s) can be updated.${reset}"
    echo "${yellow}Run 'vp-vm list-upgradable' to see them.${reset}"