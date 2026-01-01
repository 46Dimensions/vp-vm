#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[91m"
green="\033[92m"
yellow="\033[93m"
cyan="\033[1;96m"
reset="\033[0m"

# Check command ($1)
case "$1" in
    update)
        sh "$INSTALL_DIR/update-versions.sh"
        ;;
    upgrade)
        sh "$INSTALL_DIR/upgrade.sh"
        ;;
    list-upgradable)
        sh "$INSTALL_DIR/list-upgradable.sh"
        ;;
    --version)
        echo "1.0.0"
        ;;
    --help)
        # Header
        echo "${cyan}=============================================${reset}"
        echo "${cyan}Vocabulary Plus Version Manager: Help (1.0.0)${reset}"
        echo "${cyan}=============================================${reset}"
        echo "Usage: vp-vm [command]"
        echo ""
        echo "Commands:"
        echo "   update            Update the version lists"
        echo "   upgrade           Upgrade Vocabulary Plus and vp-vm to the latest version"
        echo "   list-upgradable   Show upgradable packages"
        echo "   --version         Show the installed version of Vocabulary Plus Version Manager"
        echo "   --help            Show this help message and exit"
        exit 0
        ;;
    *)
        echo "${red}Command '$1' not recognised.${reset}"
        $0 --help
        exit 1
        ;;
esac
