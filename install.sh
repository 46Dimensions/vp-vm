#!/usr/bin/env sh
set -e

# ANSI colours
red="\033[91m"
green="\033[92m"
yellow="\033[93m"
cyan="\033[96m"
blue="\033[38;5;33m"
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

write_info() {
    message=$1
    echo "${blue}${message}${reset}"
}

write_success() {
    message=$1
    echo "${green}${message}${reset}"
}

write_warning() {
    message=$1
    echo "${yellow}${message}${reset}"
}

write_error() {
    message=$1
    echo "${red}${message}${reset}"
}

echo "${purple}🭖█🭀  🭋█🭡   ${orange}██████🭏"
echo "${purple}🭦█🭐  🭅█🭛   ${orange}██   🭨█"
echo "${purple} 🭖█🭀🭋█🭡    ${orange}██████🭠"
echo "${purple} 🭦█🭐🭅█🭛    ${orange}██"
echo "${purple}  🭖██🭡     ${orange}██${reset}"
echo "VOCABULARY PLUS"
echo "Version Manager: macOS & Linux Installation (2.0.0)"
echo ""

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

download_file() {
	filename=$1

	write_progress "- Downloading $filename..."

	url="$BASE_URL/$filename"
	curl -fsSL "$url" -o "$INSTALL_DIR/$filename" || { write_error "Unable to download $filename"; exit 1; }
}

VM_DIR="$HOME/.vp-vm"
INSTALL_DIR="$VM_DIR/scripts"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
add_to_path "$BIN_DIR"

write_progress "Downloading files..."
BASE_URL="https://raw.githubusercontent.com/46Dimensions/vp-vm/2.0.0"
download_file vp-vm.sh
download_file LICENSE
download_file README.md
write_success "Downloaded files."

write_progress "Setting up launchers..."

write_progress "- VP VM launcher"
vm_launcher_path="$BIN_DIR/vp-vm"
cat > "$vm_launcher_path" <<EOF
#!/usr/bin/env sh
sh $INSTALL_DIR/vp-vm.sh \$@
exit \$?
EOF
chmod +x "$vm_launcher_path"

write_progress "- Vocabulary Plus launcher"
vocabularyplus_launcher_path="$BIN_DIR/vocabularyplus"
cat > "$vocabularyplus_launcher_path" <<EOF
#!/usr/bin/env sh
sh $VM_DIR/versions/$(cat "$VM_DIR/current.txt")/vp-vm.sh \$@
exit \$?
EOF
chmod +x "$vocabularyplus_launcher_path"

write_progress "- Vocabulary Plus launcher alias"
vp_launcher_path="$BIN_DIR/vp"
cp -vf "$vocabularyplus_launcher_path" "$vp_launcher_path"
chmod +x "$vp_launcher_path"

write_success "Launchers set up."

write_progress "Creating required files..."
echo "2.0.0" > "$VM_DIR/version.txt"

write_success "Successfully installed Vocabulary Plus Version Manager v2.0.0."
write_info "See $INSTALL_DIR/README.md or https://github.com/46Dimensions/vp-vm/blob/2.0.0/README.md for instructions."