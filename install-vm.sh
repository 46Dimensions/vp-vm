#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[91m"
green="\033[92m"
yellow="\033[93m"
cyan="\033[1;96m"
reset="\033[0m"

# Set install directory
if [ -z "$1" ]; then
    echo "Usage: $0 <install-directory> [-s|--silent]"
    exit 1
fi
INSTALL_DIR="$1"

# Disable stdout if $2 is -s or --silent
SILENT=0
case "$2" in
  -s|--silent) SILENT=1 ;;
esac

if [ "$SILENT" -eq 1 ]; then
  exec >/dev/null
fi

echo "${cyan}=======================================================${reset}"
echo "${cyan}Vocabulary Plus Version Manager: Unix Installer (1.0.0)${reset}"
echo "${cyan}=======================================================${reset}"
echo ""

# Check that curl exists
if ! command -v curl >/dev/null 2>&1; then
    echo "${red}Error: curl is not installed. Please install curl and try again.${reset}"
    exit 1
fi

# Create installation directory if it doesn't exist
echo "${yellow}Creating installation directory (${INSTALL_DIR})...${reset}"
mkdir -p "$INSTALL_DIR"
echo "${green}Installation directory created.${reset}"
echo ""

# Create the directories for version files
echo "${yellow}Creating versions directory...${reset}"
mkdir -p "$INSTALL_DIR/versions"
mkdir -p "$INSTALL_DIR/versions/vp"
mkdir -p "$INSTALL_DIR/versions/vp-vm"
echo "${green}Versions directory created.${reset}"
echo ""

# Write vp-vm current version file
echo "${yellow}Setting up current version file...${reset}"
echo "1.0.0" > "$INSTALL_DIR/versions/vp-vm/current.txt"
echo "${green}Current version file set up.${reset}"
echo ""

# Function to add "$INSTALL_DIR" to the 3rd line of the downloaded scripts
write_script_with_install_dir() {
  contents=$1
  out=$2

  printf '%s\n' "$contents" | awk -v install_dir="$INSTALL_DIR" '
    NR == 1 { print; next }
    NR == 2 && $0 ~ /^set -e/ {
      print
      print ""
      print "INSTALL_DIR=\"" install_dir "\""
      print ""
      next
    }
    { print }
  ' > "$out"

  chmod +x "$out"
}

# Download the scripts
echo "${yellow}Downloading scripts...${reset}"
BASE_URL="https://raw.githubusercontent.com/46Dimensions/vp-vm/main"
UPDATER_CONTENTS=$(curl -fsSL "$BASE_URL/update-versions.sh" || { echo "${red}Failed to download version updater script.${reset}" >&2; exit 1; })
UPGRADER_CONTENTS=$(curl -fsSL "$BASE_URL/upgrade.sh" || { echo "${red}Failed to download upgrader script.${reset}" >&2; exit 1; })
UNINSTALLER_CONTENTS=$(curl -fsSL "$BASE_URL/uninstall.sh" || { echo "${red}Failed to download uninstaller.${reset}" >&2; exit 1; })
LISTER_CONTENTS=$(curl -fsSL "$BASE_URL/list-upgradable.sh" || { echo "${red}Failed to download upgradable package lister.${reset}" >&2; exit 1; })
MAIN_CONTENTS=$(curl -fsSL "$BASE_URL/vp-vm.sh" || { echo "${red}Failed to download upgrader script.${reset}" >&2; exit 1; })
echo "${green}Scripts downloaded successfully.${reset}"

# Write the scripts with the correct INSTALL_DIR
echo ""
echo "${yellow}Configuring scripts...${reset}"
write_script_with_install_dir "$UPDATER_CONTENTS" "$INSTALL_DIR/update-versions.sh"
write_script_with_install_dir "$UPGRADER_CONTENTS" "$INSTALL_DIR/upgrade.sh"
write_script_with_install_dir "$UNINSTALLER_CONTENTS" "$INSTALL_DIR/uninstall.sh"
write_script_with_install_dir "$LISTER_CONTENTS" "$INSTALL_DIR/list-upgradable.sh"
write_script_with_install_dir "$MAIN_CONTENTS" "$HOME/.local/bin/vp-vm"
chmod +x "$HOME/.local/bin/vp-vm"
echo "${green}Scripts configured successfully.${reset}"
echo ""

# Final instructions
echo "${green}Vocabulary Plus Version Manager 1.0.0 installed successfully${reset}"
echo "For instructions on how to use the version manager, please visit: https://github.com/46Dimensions/vp-vm/blob/main/README.md"