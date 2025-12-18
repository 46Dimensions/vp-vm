#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
reset="\033[0m"

# Check command ($1)
case "$1" in
    update)
        sh "$INSTALL_DIR/update-versions.sh"
        ;;
    upgrade)
        sh "$INSTALL_DIR/upgrade.sh"
        ;;
    --version)
        echo "0.2.0"
        ;;
    --help)
        # Header
        echo "${green}=======================================${reset}"
        echo "${green}Vocabulary Plus Version Manager (0.2.0)${reset}"
        echo "${green}=======================================${reset}"
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "   update      Update the version lists"
        echo "   upgrade     Upgrade Vocabulary Plus and vp-vm to the latest version"
        echo "   --version   Show the installed version of Vocabulary Plus Version Manager"
        echo "   --help      Show this help message and exit"
        exit 0
        ;;
    *)
        echo "${red}Command '$1' not recognised.${reset}"
        echo "${yellow}Use '$0 --help' to see commands${reset}"
        exit 1
        ;;
esac
