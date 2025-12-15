#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
reset="\033[0m"

echo "${green}=========================================================${reset}"
echo "${green}Vocabulary Plus Version Manager: Package Upgrader (1.0.0)${reset}"
echo "${green}=========================================================${reset}"

# Get the Vocabulary Plus version to upgrade to
VP_CURRENT=$(cat $INSTALL_DIR/versions/vp/current.txt)
VP_LATEST=$(cat $INSTALL_DIR/versions/vp/latest.txt)
# Set the Vocabulary Plus upgrade flag
if [ "$VP_CURRENT" != "$VP_LATEST" ]; then
    UPGRADE_VP=true
else
    UPGRADE_VP=false
fi

# Get the Vocabulary Plus Version Manager version to upgrade to
VM_CURRENT=$(cat $INSTALL_DIR/versions/vp-vm/current.txt)
VM_LATEST=$(cat $INSTALL_DIR/versions/vp-vm/latest.txt)
# Set the Vocabulary Plus Version Manager upgrade flag
if [ "$VM_CURRENT" != "$VM_LATEST" ]; then
    UPGRADE_VM=true
else
    UPGRADE_VM=false
fi