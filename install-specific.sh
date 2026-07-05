#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[91m"
green="\033[92m"
yellow="\033[93m"
boldcyan="\033[1;96m"
cyan="\033[96m"
reset="\033[0m"

$VERSION = $1
if [ "$VERSION" = "" ]; then
    echo "${red}ERROR: No version specified. Please specify a version to install.${reset}"
    exit 1
fi

if [ "$VERSION" = "latest" ]; then
    echo "${yellow}Reading package lists...${reset}"
    # Get the Vocabulary Plus version to install
    VP_LATEST=$(cat "$INSTALL_DIR/versions/vp/latest.txt")
    VERSION=$VP_LATEST
fi

if [ "$VERSION" = "v*" ]; then
    VERSION="${VERSION:1}"
fi

echo "${yellow}Dwonloading Vocabulary Plus version ${VERSION}...${reset}"
URL="https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/v${VERSION}/install.sh"
curl -fsSL "$URL" -o install.sh || { echo "${red}Version ${VERSION} does not exist${reset}"; exit 1; }

echo "${yellow}Installing Vocabulary Plus version ${VERSION}...${reset}"
sh ./install.sh || { echo "${red}Failed to install VocabularyPlus.${reset}"; exit 1; }

echo "${green}Vocabulary Plus version ${VERSION} installed successfully.${reset}"