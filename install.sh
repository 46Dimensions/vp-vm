#!/usr/bin/env sh
set -e

VERSION="v2.0.0-beta1"
VERSION_DISPLAY="2.0.0 Beta 1"
DEVELOPMENT_BRANCH="2.0.0"

check_branch_exists() {
    branch=$1

    status=$(curl -sSL \
        -o /dev/null \
        -w '%{http_code}' \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/46Dimensions/vp-vm/branches/$branch")

    if [ "$status" = 200 ]; then
        return 0
    elif [ "$status" = 404 ]; then
        return 1
    else
        echo "Unable to detect download branch"
        exit 1
    fi
}

get_url() {
    url="$1"

    body=$(mktemp)
    status=$(curl -sSL -w '%{http_code}' -o "$body" "$url")

    case "$status" in
        200)
            cat "$body"
            rm -f "$body"
            return 0
            ;;
        404)
            rm -f "$body"
            return 1
            ;;
        *)
            rm -f "$body"
            return 2
            ;;
    esac
}

main_branch_version=$(get_url "https://raw.githubusercontent.com/46Dimensions/vp-vm/main/VERSION.txt")
case "$main_branch_version" in
    *"$DEVELOPMENT_BRANCH"*)
        BRANCH="main"
        ;;
    *)
        if check_branch_exists "$DEVELOPMENT_BRANCH"; then
            BRANCH="$DEVELOPMENT_BRANCH"
        else
            echo "Unable to determine download branch"
            exit 1
        fi
esac

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

if [ "$SILENT" = "1" ]; then
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

KERNEL=$(uname)
if [ "$KERNEL" = "Linux" ]; then
    PLATFORM="Linux"
elif [ "$KERNEL" = "Darwin" ]; then
    PLATFORM="MacOS"
else
    echo "${red}Unable to determine your system. Found: '${KERNEL}'${reset}"
    exit 1
fi

write_logo() {
	echo "${purple}🭖█🭀  🭋█🭡   ${orange}██████🭏"
	echo "${purple}🭦█🭐  🭅█🭛   ${orange}██   🭨█"
	echo "${purple} 🭖█🭀🭋█🭡    ${orange}██████🭠"
	echo "${purple} 🭦█🭐🭅█🭛    ${orange}██"
	echo "${purple}  🭖██🭡     ${orange}██${reset}"
	echo "VOCABULARY PLUS"
	echo "Version Manager: $PLATFORM Installation ($VERSION_DISPLAY)"
	echo ""
}

add_to_path() {
    directory=$1

    # Already in PATH.
    case ":$PATH:" in
        *":$directory:"*)
            return 0
            ;;
    esac

    shell_name=$(basename "$SHELL")

    case "$shell_name" in
        bash)
            config_file="$HOME/.bashrc"
            printf '\n# Added by Vocabulary Plus\nexport PATH="%s:$PATH"\n' "$directory" \
                >> "$config_file"
            ;;
        zsh)
            config_file="$HOME/.zshrc"
            printf '\n# Added by Vocabulary Plus\nexport PATH="%s:$PATH"\n' "$directory" \
                >> "$config_file"
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            mkdir -p "$(dirname "$config_file")"
            printf '\n# Added by Vocabulary Plus\nfish_add_path "%s"\n' "$directory" \
                >> "$config_file"
            ;;
        *)
            config_file="$HOME/.profile"
            printf '\n# Added by Vocabulary Plus\nexport PATH="%s:$PATH"\n' "$directory" \
                >> "$config_file"
            ;;
    esac

    # Make it available to the current installer process too.
    export PATH="$directory:$PATH"
}

download_file() {
	filename=$1

	write_progress "- Downloading $filename..."

	url="$BASE_URL/$filename"
	curl -fsSL "$url" -o "$INSTALL_DIR/$filename" || { write_error "Unable to download $filename"; exit 1; }
}

write_logo

VM_DIR="$HOME/.vp-vm"
INSTALL_DIR="$VM_DIR/scripts"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
add_to_path "$BIN_DIR"

write_progress "Downloading files..."
BASE_URL="https://raw.githubusercontent.com/46Dimensions/vp-vm/$BRANCH"
download_file vp-vm.sh
download_file LICENSE
download_file README.md
write_success "Downloaded files successfully."

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
sh $VM_DIR/versions/\$(cat "$VM_DIR/current.txt")/vp-vm.sh \$@
exit \$?
EOF
chmod +x "$vocabularyplus_launcher_path"

write_progress "- Vocabulary Plus launcher alias"
vp_launcher_path="$BIN_DIR/vp"
cp -f "$vocabularyplus_launcher_path" "$vp_launcher_path"
chmod +x "$vp_launcher_path"

write_success "Launchers set up."

write_progress "Creating required files..."
echo "$VERSION" > "$VM_DIR/version.txt"
echo "$VERSION_DISPLAY" > "$VM_DIR/version-display.txt"

write_success "Successfully installed Vocabulary Plus Version Manager $VERSION_DISPLAY."
echo ""
write_info "Instructions and Help:"
write_info "$BIN_DIR/vp-vm --help"
write_info "$INSTALL_DIR/README.md"
write_info "https://github.com/46Dimensions/vp-vm/blob/$BRANCH/README.md"