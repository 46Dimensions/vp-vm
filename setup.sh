#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[91m"
green="\033[92m"
yellow="\033[93m"
reset="\033[0m"

# Disable stdout if $2 is -s or --silent
SILENT=0
case "$2" in
  -s|--silent) SILENT=1 ;;
esac

if [ "$SILENT" -eq 1 ]; then
  exec >/dev/null
fi

echo "[38;5;99m🭖█🭀  🭋█🭡   [38;5;171m██████🭏"
echo "[38;5;105m🭦█🭐  🭅█🭛   [38;5;177m██   🭨█"
echo "[38;5;141m 🭖█🭀🭋█🭡    [38;5;183m██████🭠"
echo "[38;5;177m 🭦█🭐🭅█🭛    [38;5;209m██"
echo "[38;5;209m  🭖██🭡     [38;5;220m██[0m"
echo "VOCABULARY PLUS"
echo "Version Manager: macOS & Linux Setup (2.0.0)"
echo ""

# Function to get the directory of this script
get_script_dir() {
    script_dir=$(dirname -- "$0")
    case $script_dir in
        /*) printf '%s\n' "$script_dir" ;;
        *) printf '%s\n' "$PWD/$script_dir" ;;
    esac
}

add_to_path() {
	directory=$1

	case ":$PATH:" in
		*":$directory:"*)
		    return 0
		    ;;
	esac

	printf '\n# Added by Vocabulary Plus\nexport PATH="%s:$PATH"\n' "$directory" \
		>> "$HOME/.profile"

	export PATH="$directory:$PATH"
}

file_dir=$(get_script_dir)
INSTALL_DIR="$(dirname "$(dirname "$(dirname "$file_dir")")")"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$BIN_DIR"
add_to_path "$BIN_DIR"

if [ ! -f "$INSTALL_DIR/vp-vm" ]; then
    echo "${red}Installed script not found at $INSTALL_DIR/vp-vm.${reset}" >&2
    exit 1
fi

chmod +x "$INSTALL_DIR/vp-vm" || { echo "${red}Failed to make vp-vm executable.${reset}" >&2; exit 1; }
ln -sfn "$INSTALL_DIR/vp-vm" "$HOME/.local/bin/vp-vm" || { echo "${red}Failed to create symlink for vp-vm.${reset}" >&2; exit 1; }

echo "${green}Scripts configured successfully.${reset}"
echo ""

# Final instructions
echo "${green}Vocabulary Plus Version Manager 1.2.4 installed successfully${reset}"
echo "For instructions on how to use the version manager, please visit: https://github.com/46Dimensions/vp-vm"
exit 0