#!/usr/bin/env sh
set -e

# ANSI colours
green="\033[92m"
yellow="\033[93m"
purple="\033[38;5;93m"
orange="\033[38;5;208m"
reset="\033[0m"

# Disable stdout if $2 is -s or --silent
SILENT=0
case "$2" in
  -s|--silent) SILENT=1 ;;
esac

if [ "$SILENT" -eq 1 ]; then
  exec >/dev/null
fi

echo "${purple}🭖█🭀  🭋█🭡   ${orange}██████🭏"
echo "${purple}🭦█🭐  🭅█🭛   ${orange}██   🭨█"
echo "${purple} 🭖█🭀🭋█🭡    ${orange}██████🭠"
echo "${purple} 🭦█🭐🭅█🭛    ${orange}██"
echo "${purple}  🭖██🭡     ${orange}██${reset}"
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

  echo "${yellow}Adding $directory to PATH${reset}"

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
INSTALL_DIR="$file_dir"
BIN_DIR="$HOME/.local/bin"
echo "INSTALL_DIR: $INSTALL_DIR"
echo "BIN_DIR: $BIN_DIR"

mkdir -p "$BIN_DIR"
add_to_path "$BIN_DIR"

echo "${yellow}Setting up launcher...${reset}"
launcher="$BIN/vp-vm"

cat > "$launcher" << EOF
$INSTALL_DIR/vp-vm.sh
EOF

# Final instructions
echo "${green}Vocabulary Plus Version Manager 2.0.0 set up successfully${reset}"
echo "For instructions on how to use the version manager, please visit: https://github.com/46Dimensions/vp-vm"
exit 0