#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
reset="\033[0m"

# Disable stdout if $1 is -s or --silent
SILENT=0
case "$1" in
  -s|--silent) SILENT=1 ;;
esac

if [ "$SILENT" -eq 1 ]; then
  exec >/dev/null
fi


echo "${green}====================================================${reset}"
echo "${green}Vocabulary Plus Version Manager: Uninstaller (0.3.0)${reset}"
echo "${green}====================================================${reset}"
sleep 1

cd "$INSTALL_DIR"

# Remove the VocabularyPlus/vm directory ("$INSTALL_DIR")
echo ""
echo "${yellow}Removing vm directory...${reset}"
# If the working directory is about to be removed, 
# change to the parent directory (should be 'VocabularyPlus')
if [ "$PWD" = ""$INSTALL_DIR"" ]; then
    cd ..
fi
rm -rf "$INSTALL_DIR"
sleep 0.25
echo "${green}Directory removed${reset}"
sleep 0.5

# Remove the control script (vp-vm)
echo ""
echo "${yellow}Removing control script...${reset}"
rm "$HOME/.local/bin/vp-vm"
sleep 0.25
echo "${green}Control script removed.${reset}"
sleep 0.5

# Final message
echo ""
echo "${green}Vocabulary Plus Version Manager 0.3.0 successfully uninstalled.${reset}"
echo "${yellow}If you found any errors in Vocabulary Plus Version Manager, please report them at https://github.com/46Dimensions/vp-vm/issues ${reset}"