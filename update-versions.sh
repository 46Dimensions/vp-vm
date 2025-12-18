#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[94m"
purple="\033[35m"
reset="\033[0m"

# Header
echo "${green}========================================================${reset}"
echo "${green}Vocabulary Plus Version Manager: Version Updater (0.3.0)${reset}"
echo "${green}========================================================${reset}"

# Function to get the contents of a version file
extract_version() {
    file_path="$1"
    echo "${purple}READ: ${file_path}${reset}" >&2
    if [ -f "$file_path" ]; then
        cat "$file_path"
    else
        echo "${red}Error: File '$file_path' not found.${reset}" >&2
        exit 1
    fi
}

# Get most recent versions of Vocabulary Plus and Vocabulary Plus Version Manager
# Save them to "$INSTALL_DIR"/versions
VP_URL=https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/vp-vm/version.txt
echo "${blue}GET: ${VP_URL} ${reset}"
curl -fsSL $VP_URL -o "$INSTALL_DIR"/versions/vp/latest.txt || { echo "$(curl -fsSL $VP_URL)" > "$INSTALL_DIR"/versions/vp/latest.txt; } || { echo "${red} Error getting latest version of Vocabulary Plus.${reset}"; exit 1; }
VP_VM_URL=https://raw.githubusercontent.com/46Dimensions/vp-vm/main/version.txt
echo "${blue}GET: ${VP_VM_URL} ${reset}"
curl -fsSL $VP_VM_URL -o "$INSTALL_DIR"/versions/vp-vm/latest.txt || { echo "${red} Error getting latest version of Vocabulary Plus Version Manager.${reset}"; exit 1; }
sleep 1

# Extract versions from downloaded files
VP_VERSION=$(extract_version ""$INSTALL_DIR"/versions/vp/latest.txt")
sleep 0.25
VP_VM_VERSION=$(extract_version ""$INSTALL_DIR"/versions/vp-vm/latest.txt")
sleep 0.5

# Get currently installed versions
CURRENT_VP_VERSION=$(extract_version ""$INSTALL_DIR"/versions/vp/current.txt")
sleep 0.25
CURRENT_VP_VM_VERSION=$(extract_version ""$INSTALL_DIR"/versions/vp-vm/current.txt")
sleep 1

echo ""
echo "${yellow}Checking for updates...${reset}"
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
sleep 1

# Print summary
if [ -z "$UPDATABLE_PACKAGES" ]; then
    echo "${green}All packages are up to date.${reset}"
else
    echo "${yellow}${UPDATABLE_PACKAGES} package(s) can be updated.${reset}"
fi
