#!/usr/bin/env sh
set -e

INSTALL_DIR="/home/dmcbbjt/dev/vp-test/VocabularyPlus/vm"


# ANSI colours
red="\033[91m"
green="\033[92m"
yellow="\033[93m"
boldcyan="\033[1;96m"
cyan="\033[96m"
reset="\033[0m"

VERSION="$1"
if [ -z "$VERSION" ]; then
    echo "${red}ERROR: No version specified. Please specify a version to install.${reset}"
    exit 1
fi

if [ "$VERSION" = "latest" ]; then
    echo "${yellow}Reading package lists...${reset}"
    # Get the Vocabulary Plus version to install
    VP_LATEST=$(cat "$INSTALL_DIR/versions/vp/latest.txt") || { echo "${yellow}Unable to get latest version. Run 'vp-vm update' to load latest version.${reset}"; exit 1; }
    VERSION=$VP_LATEST
fi

# Remove trailing 'v' from version if present
case "$VERSION" in
    v*)
        VERSION="${VERSION#v}"
        ;;
esac

if [ "$VERSION" = "1.1.0" ]; then
    VERSION="1.1"
fi

INVALID_VERSIONS="1.1 1.2.0 1.3.0-beta 1.3.0 1.4.0"

for invalid in $INVALID_VERSIONS; do
    if [ "$VERSION" = "$invalid" ]; then
        echo "${red}Version ${VERSION} cannot be installed.${reset}"
        exit 1
    fi
done

# Move the JSON files and VM into a temporary location
if [ -d "$INSTALL_DIR" ]; then
    echo "${yellow}Backing up vocabulary files...${reset}"
    cd "$INSTALL_DIR"
    cd .. # Move into VocabularyPlus directory
    cd .. # Move into VocabularyPlus's parent directory
    mkdir -p VocabularyPlusTemp
    mv VocabularyPlus/JSON VocabularyPlusTemp/JSON || { echo "${red}WARNING: ${PWD}/VocabularyPlus/JSON not found so not backed up${reset}"; } # This problem is not critical; VocabularyPlus/JSON is not created until main.py is run
    mv VocabularyPlus/vm VocabularyPlusTemp/vm || { echo "${red}ERROR: ${PWD}/VocabularyPlus/vm not found so not backed up${reset}"; exit 1; }
    echo "${green}Vocabulary files backed up.${reset}"
    sleep 0.5

    echo ""
    echo "${yellow}Uninstalling current Vocabulary Plus version...${reset}"
    # Run the Vocabulary Plus uninstaller
    $HOME/.local/bin/vp uninstall -s

    echo "${green}Current Vocabulary Plus version uninstalled.${reset}"
    sleep 0.5
fi

echo ""

# Install the latest version
echo "${yellow}Installing Vocabulary Plus version ${VERSION}...${reset}"
curl -fsSL "https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/v${VERSION}/install.sh" -o install.sh || { echo "${red}Failed to download install.sh for version ${VERSION}. Check that the version exists.${reset}"; exit 1; }
sh install.sh -s
# Abort if installation fails
if [ $? != 0 ]; then
    echo "${red}Installation failed.${reset}"
    rm install.sh
    exit 1
fi
rm install.sh
sleep 0.5

if [ -d "VocabularyPlusTemp" ]; then
    echo ""
    # Move the JSON files and VM back into VocabularyPlus directory
    if [ -d "VocabularyPlus/JSON" ]; then
        rm -rf VocabularyPlus/JSON
    fi

    if [ -d "VocabularyPlus/vm" ]; then
        rm -rf VocabularyPlus/vm
    fi
    mv "VocabularyPlusTemp/JSON" "VocabularyPlus/JSON" || { echo "${yellow}WARNING: ${PWD}/VocabularyPlusTemp/JSON not found so not backed up${reset}"; } # This problem is not critical; VocabularyPlus/JSON is not created until main.py is run
    mkdir -p "VocabularyPlus/vm" || { echo "${red}ERROR: Failed to create ${PWD}/VocabularyPlus/vm directory${reset}"; exit 1; }
    mv "VocabularyPlusTemp/vm" "VocabularyPlus/vm" || { echo "${red}ERROR: ${PWD}/VocabularyPlusTemp/vm not found so not backed up${reset}"; exit 1; }
    rm -rf VocabularyPlusTemp
fi

echo "${green}Vocabulary Plus version ${VERSION} installed successfully.${reset}"