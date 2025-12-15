#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
reset="\033[0m"

# Set install directory
if [ -z "$1" ]; then
    echo "Usage: $0 <install-directory>"
    exit 1
fi
INSTALL_DIR="$1"

echo "${green}==================================================${reset}"
echo "${green}Vocabulary Plus Version Manager: Installer (1.0.0)${reset}"
echo "${green}==================================================${reset}"
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
echo "1.0.0" > "$INSTALL_DIR/versions/vp-vm/current"
echo "${green}Current version file set up.${reset}"
echo ""

# Function to add $INSTALL_DIR to the 3rd line of the downloaded scripts
write_script_with_install_dir() {
  local contents="$1"
  local out="$2"

  awk -v install_dir="$INSTALL_DIR" '
    NR == 1 { print; next }
    NR == 2 && $0 ~ /^set -e/ {
      print
      print ""
      print "INSTALL_DIR=\"" install_dir "\""
      print ""
      next
    }
    { print }
  ' <<< "$contents" > "$out"

  chmod +x "$out"
}

# Download the scripts
echo "${yellow}Downloading scripts...${reset}"
UPDATER_CONTENTS=$(curl -fsSL "https://raw.githubusercontent.com/46Dimensions/vp-vm/main/update-versions.sh" || { echo "${red}Failed to download version updater script.${reset}"; exit 1; })
UPGRADER_CONTENTS=$(curl -fsSL "https://raw.githubusercontent.com/46Dimensions/vp-vm/main/upgrade.sh" || { echo "${red}Failed to download upgrader script.${reset}"; exit 1; })
MAIN_CONTENTS=$(curl -fsSL "https://raw.githubusercontent.com/46Dimensions/vp-vm/main/vm.sh" || { echo "${red}Failed to download upgrader script.${reset}"; exit 1; })
echo "${green}Scripts downloaded successfully.${reset}"

# Write the scripts with the correct INSTALL_DIR
echo "${yellow}Configuring scripts...${reset}"
write_script_with_install_dir "$UPDATER_CONTENTS" "$INSTALL_DIR/update-versions.sh"
write_script_with_install_dir "$UPGRADER_CONTENTS" "$INSTALL_DIR/upgrade.sh"
write_script_with_install_dir "$MAIN_CONTENTS" "$INSTALL_DIR/vm.sh"
echo "${green}Scripts configured successfully.${reset}"
echo ""

# Final instructions
echo "${green}Successfully installed Vocabulary Plus Version Manager 1.0.0.${reset}"
echo ""
echo "For instructions on how to use the version manager, please visit: https://github.com/46Dimensions/vp-vm/blob/main/README.md"