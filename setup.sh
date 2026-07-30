#!/usr/bin/env sh
set -e

# ANSI colours
green="\033[92m"
cyan="\033[96m"
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

write_progress() {
    message=$1
    echo "${cyan}${message}${reset}"
}

write_success() {
    message=$1
    echo "${green}${message}${reset}"
}

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

	write_progress "Adding $directory to PATH..."

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
INSTALL_DIR="$file_dir/scripts"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
add_to_path "$BIN_DIR"

write_progress "Moving files to $INSTALL_DIR"
mv "$file_dir/*" "$INSTALL_DIR" 2>/dev/null

write_progress "Setting up launcher..."
launcher="$BIN_DIR/vp-vm"

cat > "$launcher" << EOF
$INSTALL_DIR/vp-vm.sh
EOF

# Final instructions
write_success "Vocabulary Plus Version Manager 2.0.0 set up successfully"
echo "For instructions on how to use the version manager, please visit: https://github.com/46Dimensions/vp-vm"
exit 0