#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[91m"
green="\033[92m"
yellow="\033[93m"
blue="\033[94m"
reset="\033[0m"

sleep 0.5
echo "${yellow}Listing...${reset}"
sleep 1

# Function to get the contents of a version file
extract_version() {
    file_path="$1"
    if [ -f "$file_path" ]; then
        cat "$file_path"
    else
        echo "${red}Error: File '$file_path' not found.${reset}" >&2
        exit 1
    fi
}

# Extract versions from downloaded files
VP_VERSION=$(extract_version "$INSTALL_DIR/versions/vp/latest.txt")
sleep 0.25
VP_VM_VERSION=$(extract_version "$INSTALL_DIR/versions/vp-vm/latest.txt")
sleep 0.25

# Get currently installed versions
CURRENT_VP_VERSION=$(extract_version "$INSTALL_DIR/versions/vp/current.txt")
sleep 0.25
CURRENT_VP_VM_VERSION=$(extract_version "$INSTALL_DIR/versions/vp-vm/current.txt")
sleep 1

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

# Print list
if [ "$VP_NEEDS_UPDATE" = true ]; then
    echo "${blue}Vocabulary Plus${reset} (${red}${CURRENT_VP_VERSION}${reset} -> ${green}${VP_VERSION}${reset})"
fi
sleep 0.5
if [ "$VP_VM_NEEDS_UPDATE" = true ]; then
    echo "${blue}Vocabulary Plus Version Manager${reset} (${red}${CURRENT_VP_VM_VERSION}${reset} -> ${green}${VP_VM_VERSION}${reset})"
fi
sleep 0.5