#!/usr/bin/env sh

# ANSI colours
red="\033[91m"
green="\033[92m"
yellow="\033[93m"
cyan="\033[96m"
blue="\033[38;5;33m"
reset="\033[0m"

# Global variables
SCRIPTS_DIR="$HOME/.vp-vm/scripts" # ~/.vp-vm/scripts
MAIN_DIR="$(dirname -- "$SCRIPTS_DIR")" # ~/.vp-vm
DOWNLOAD_DIR="$MAIN_DIR/download" # ~/.vp-vm/download
VERSIONS_DIR="$MAIN_DIR/versions" # ~/.vp-vm/versions
BIN_DIR="$HOME/.local/bin"

KERNEL=$(uname)
if [ "$KERNEL" = "Linux" ]; then
    PLATFORM="Linux"
elif [ "$KERNEL" = "Darwin" ]; then
    PLATFORM="MacOS"
else
    echo "${red}Unable to determine your system. Found: '${KERNEL}'${reset}"
    exit 1
fi

VP_VM_VERSION=$(cat "$MAIN_DIR/version.txt")
VP_VM_DISPLAY_VERSION=$(cat "$MAIN_DIR/version.txt")

mkdir -p "$SCRIPTS_DIR" "$MAIN_DIR" "$DOWNLOAD_DIR" "$VERSIONS_DIR"

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

normalise_version() {
    version=$1
    [ "$version" = latest ] && version=$(list_remote_versions | get_latest_version)
    case $version in v*) version=${version#v};; esac

    IFS=. read -r major minor rest <<EOF
$version
EOF

    case $minor in ''|*[!0-9]*) minor=0;; esac
    patch=${rest%%-*}
    case $rest in *-*) suffix=${rest#"$patch"};; *) suffix=;; esac
    case $patch in ''|*[!0-9]*) patch=0;; esac

    case $major in ''|*[!0-9]*) return 1;; esac
    [ "$major" -ge 2 ] || return 1
    case $suffix in ''|-alpha*|-beta*) ;; *) return 1;; esac

    printf 'v%s.%s.%s%s\n' "$major" "$minor" "$patch" "$suffix"
}


get_latest_version() {
    awk '
    function rank(pre) {
        if (pre == "") return 3
        if (pre ~ /^alpha[0-9]*$/) return 1
        if (pre ~ /^beta[0-9]*$/) return 2
        return -1
    }

    function number(pre) {
        sub(/^[a-z]+/, "", pre)
        return pre == "" ? 0 : pre + 0
    }

    function newer(version, latest,    v, l, vr, lr, i) {
        sub(/^v/, "", version)
        sub(/^v/, "", latest)

        split(version, v, "-")
        split(latest, l, "-")

        split(v[1], v, ".")
        split(l[1], l, ".")

        for (i = 1; i <= 3; i++)
            if (v[i] != l[i])
                return (v[i] + 0) > (l[i] + 0)

        vr = rank(v[2])
        lr = rank(l[2])

        if (vr < 0 || lr < 0) {
            exit 1
        }

        return vr != lr ? vr > lr : number(v[2]) > number(l[2])
    }

    /^[[:space:]]*$/ { next }

    {
        if (!latest) {
            latest = $0
            next
        }

        if (newer($0, latest))
            latest = $0
    }

    END {
        if (latest)
            print latest
    }
    '
}

list_remote_versions() {
    curl -fsSL "https://api.github.com/repos/46Dimensions/VocabularyPlus/tags?per_page=100" |
        jq -r '.[].name' |
        while IFS= read -r tag; do
            normalise_version "$tag"
        done
}

list_installed_versions() {
    for version in "$VERSIONS_DIR"/*; do
        [ -e "$version" ] || continue
        printf '%s\n' "${version##*/}"
    done
}

download_version() {
    version="$1"

    normalised=$(normalise_version "$version")

    if [ -n "$normalised" ] || list_remote_versions | grep -Fxq "$normalised"; then
        echo "Downloading version $normalised..."
        URL="https://github.com/46Dimensions/VocabularyPlus/releases/download/${normalised}/VocabularyPlus.zip"
        FILE_PATH="${DOWNLOAD_DIR}/vocabularyplus_${normalised}.zip"

        curl -fsSL "$URL" -o "$FILE_PATH" || { write_error "Unable to download version $normalised. Does it exist?"; exit 1; }
    else
        write_error "Version $version is invalid or does not exist."
        exit 1
    fi
}

unpack_zip() {
    zip_file=$1

    if [ -f "$zip_file" ]; then
        basename=$(basename "$zip_file")
        version=${basename#vocabularyplus_}
        version=${version%.zip}

        write_progress "Unpacking ZIP file ${basename} (version $version)..."

        OUTPUT_DIR="$VERSIONS_DIR/$version"
        unzip -q "$zip_file" -d "$OUTPUT_DIR" || { write_error "Failed to unzip file."; exit 1; }
    else
        write_error "ZIP file not found: $zip_file"
        return 1
    fi
}

run_script() {
    script_path=$1

    sh "$script_path"
}

install_version() {
    version=$1

    normalised=$(normalise_version "$version")

    if [ -n "$normalised" ]; then
        if ! list_installed_versions | grep -Fxq "$normalised"; then
            download_version "$normalised"
            
            zip_path="${DOWNLOAD_DIR}/vocabularyplus_${normalised}.zip"

            unpack_zip "$zip_path"
        else
            write_warning "Version $normalised is already downloaded."

            if [ ! -d "$VERSIONS_DIR/$normalised/installation" ]; then
                write_error "Version $normalised is already installed."
            fi
        fi

        VP_DIR="$VERSIONS_DIR/$normalised"
        SETUP_SCRIPT_PATH="$VP_DIR/installation/$PLATFORM/setup.sh"

        run_script "$SETUP_SCRIPT_PATH"
        
        echo ""
        write_success "Successfully installed Vocabulary Plus $version."
        write_info "Run '$0 use $normalised' to make it the default."
    else
        write_error "Invalid version: '$version'"
        return 1
    fi
}

uninstall_version() {
    version=$1

    normalised=$(normalise_version "$version")

    if [ -n "$normalised" ]; then
        VP_DIR="$VERSIONS_DIR/$normalised"

        if [ -s "$VP_DIR/uninstall" ]; then
            write_progress "Uninstalling $normalised..."
            run_script "$VP_DIR/uninstall"

            if [ -d "$VP_DIR" ]; then
                write_progress "Removing directory..."
                rm -rv "$VP_DIR"
            fi
            write_success "Successfully uninstalled Vocabulary Plus $normalised."
        fi
    else
        write_error "Invalid version: '$version'"
        return 1
    fi
}

set_default_version() {
    version=$1

    normalised=$(normalise_version "$version")

    if [ -n "$normalised" ]; then
        VP_DIR="$VERSIONS_DIR/$normalised"

        if [ -s "$VP_DIR/vocabularyplus" ]; then
            write_progress "Setting version $normalised as default..."
            echo "$normalised" > "$MAIN_DIR/current.txt"

            if [ "$PLATFORM" = "Linux" ]; then
                write_progress "Creating Linux desktop entry..."

                DESKTOP_FILE="$HOME/.local/share/applications/vocabularyplus.desktop"
                mkdir -p "$(dirname "$DESKTOP_FILE")"

                cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Vocabulary Plus
Exec=$VERSIONS_DIR/$(cat "$MAIN_DIR/current.txt")/vocabularyplus
Icon=$VERSIONS_DIR/$(cat "$MAIN_DIR/current.txt")/icons/icon_small.png
Terminal=true
Categories=Education;
EOF

                chmod +x "$DESKTOP_FILE"
                update-desktop-database ~/.local/share/applications 2>/dev/null || true
                write_success "Linux desktop entry created successfully."
            elif [ "$PLATFORM" = "MacOS" ]; then
                write_progress "Creating macOS .app bundle..."

                APP_DIR="$HOME/Applications/Vocabulary Plus.app"
                mkdir -p "$APP_DIR/Contents/MacOS"
                mkdir -p "$APP_DIR/Contents/Resources"

                # Copy icon & convert to .icns if sips exists
                cp "$VERSIONS_DIR/$(cat "$MAIN_DIR/current.txt")/icons/icon_small.png" "$APP_DIR/Contents/Resources/app_icon.png"
                if command -v sips >/dev/null 2>&1; then
                    sips -s format icns "$APP_DIR/Contents/Resources/app_icon.png" --out "$APP_DIR/Contents/Resources/app_icon.icns" >/dev/null 2>&1 || true
                fi

                # Launcher wrapper
                cat > "$APP_DIR/Contents/MacOS/vocabularyplus" <<EOF
#!/usr/bin/env sh
open -a Terminal
osascript  -e 'tell application "Terminal" to do script "$VERSIONS_DIR/$(cat "$MAIN_DIR/current.txt")"'
EOF
                chmod +x "$APP_DIR/Contents/MacOS/vocabularyplus"

                # Info.plist
                cat > "$APP_DIR/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>Vocabulary Plus</string>
    <key>CFBundleExecutable</key><string>vocabularyplus</string>
    <key>CFBundleIdentifier</key><string>com.vocabularyplus.app</string>
    <key>CFBundleIconFile</key><string>app_icon.icns</string>
</dict>
</plist>
EOF

                write_success "macOS .app created: $APP_DIR"
            fi

            write_success "Set version $version as default."
            write_info "You can now run 'vocabularyplus' to use it."
        else
            write_error "Unable to find version $normalised."
            return 1
        fi
    else
        write_error "Invalid version: '$version'"
        return 1
    fi
}

check_installed() {
    version=$1

    normalised=$(normalise_version "$version")

    if [ -n "$normalised" ]; then
        if list_installed_versions | grep -q "$normalised"; then
            [ ! -d "$VERSIONS_DIR/$normalised/installation" ]
            return $?
        else
            return 1
        fi
    else
        write_error "Invalid version: '$version'"
        return 1
    fi
}

show_info() {
    version=$1

    if [ "$version" = "" ]; then
        if [ -s "$MAIN_DIR/current.txt" ]; then
            current_version=$(cat "$MAIN_DIR/current.txt")
            active_executable="$VERSIONS_DIR/$current_version/vocabularyplus"
        else
            current_version="---"
            active_executable="---"
        fi
        
        latest_version=$(list_remote_versions | get_latest_version)

        count=$(list_installed_versions | grep -c '.')

        echo "VP VM $VP_VM_DISPLAY_VERSION"
        echo ""
        echo "Active version:     $current_version"
        echo "Latest available:   $latest_version"
        echo "Installed versions: $count"
        echo ""
        echo "VP VM directory:    $MAIN_DIR"
        echo "Versions directory: $VERSIONS_DIR"
        echo "Active executable:  $active_executable"
        echo ""
        echo "Platform:           $PLATFORM ($(uname -m))"
        echo "Shell:              sh"
    else
        normalised=$(normalise_version "$version")

        if [ -n "$normalised" ]; then
            if check_installed "$normalised"; then
                installed="Yes"
                directory="$VERSIONS_DIR/$normalised"
                executable="$directory/vocabularyplus"
            else
                installed="No"
                directory="---"
                executable="---"
            fi

            if [ "$(cat "$MAIN_DIR/current.txt")" = "$normalised" ]; then
                active="Yes"
            else
                active="No"
            fi

            echo "VP VM $VP_VM_DISPLAY_VERSION"
            echo ""
            echo "Version: $normalised"
            echo "Installed: $installed"
            echo "Active: $active"
            echo "Directory: $directory"
            echo "Executable: $executable"
        else
            write_error "Invalid version: '$version'"
            return 1
        fi
    fi
}

doctor() {
    write_progress "Checking versions..."

    printf '%s\n' "$(list_installed_versions)" |
    while IFS= read -r version; do
        if check_installed "$version"; then
            write_success "✓ $version"
        else
            write_error "✗ $version"
        fi
    done
}

confirm() {
    printf '%s [y/N] ' "$1"

    case "$2" in
        -y|--yes)
            answer="y"
            ;;
        *)
            read -r answer
            ;;
    esac

    case "$answer" in
        y|Y|yes|YES|Yes) return 0 ;;
        *) return 1 ;;
    esac
}

update_self() {
    get_versions() {
        curl -fsSL "https://api.github.com/repos/46Dimensions/vp-vm/tags?per_page=100" |
            jq -r '.[].name' |
            while IFS= read -r tag; do
                normalise_version "$tag"
            done
    }

    latest_version=$(get_versions | get_latest_version)
    current_version="$VP_VM_VERSION"

    if [ "$latest_version" = "$current_version" ]; then
        write_info "VP VM is already the latest version ($VP_VM_DISPLAY_VERSION)"
        return 0
    fi

    write_progress "Updating VP VM... (${red}$current_version ${cyan}-> ${green}$latest_version${cyan})"

    INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/46Dimensions/vp-vm/${latest_version}/install.sh"
    INSTALL_SCRIPT_PATH="$DOWNLOAD_DIR/vp-vm-install-${latest_version}.sh"

    # download the script
    write_progress "Downloading install script..."
    curl -fsSL "$INSTALL_SCRIPT_URL" -o "$INSTALL_SCRIPT_PATH" || { write_error "Unable to download script"; exit 1; }

    # run the script
    write_progress "Running install script..."
    run_script "$INSTALL_SCRIPT_PATH"
}

uninstall_self() {
    write_warning "VP VM will be completely uninstalled."
    write_info "This will remove:"
    write_info "- Vocabulary Plus Version Manager"
    write_info "- All installed Vocabulary Plus versions"
    write_info "- Configuration and data"
    write_info "- The $HOME/.vp-vm directory"

    if confirm "Continue?" "$1"; then
        rm -rf "$HOME/.vp-vm"
        rm -f "$BIN_DIR/vocabularyplus"
        rm -f "$BIN_DIR/vp"
    else
        write_info "Uninstallation cancelled."
    fi
}

# Help
HELP_TEXT=$(
cat <<'EOF'
Vocabulary Plus Version Manager

Usage:
    vp-vm <command> [options]

Options:
    -h, --help              Show this help message and exit
    -v, --version           Show VP VM version and exit

Core Commands:
    install <version>       Install a Vocabulary Plus version
    uninstall <version>     Uninstall a version
    use <version>           Make a version active
    list                    List installed versions
    list-remote             List available versions

Information:
    info [version]          Show information about a version
    where                   Show the VP VM directory
    which                   Show the location of the active executable

Maintenance:
    doctor                  Check that all versions are installed correctly
    cleanup                 Remove temporary files
    self-update             Update VP VM
    self-uninstall [--yes]  Uninstall VP VM and all Vocabulary Plus versions
                            --yes  Skip confirmation
EOF
)

# Handle arguments
case "$1" in
    -h|--help)
        echo "$HELP_TEXT"
        ;;
    -v|--version)
        echo "Vocabulary Plus Version Manager $VP_VM_DISPLAY_VERSION"
        ;;
    install)
        install_version "$2"
        ;;
    uninstall)
        uninstall_version "$2"
        ;;
    use)
        set_default_version "$2"
        ;;
    list|ls)
        list_installed_versions
        ;;
    list-remote|ls-remote)
        write_info "Available versions:"
        list_remote_versions
        ;;
    info)
        show_info "$2"
        ;;
    where)
        echo "$MAIN_DIR"
        ;;
    which)
        echo "$VERSIONS_DIR/$(cat "$MAIN_DIR/current.txt")/vocabularyplus"
        ;;
    doctor)
        doctor
        ;;
    cleanup)
        write_progress "Clearing downloads..."
        rm -rfv "${DOWNLOAD_DIR:?}"/*
        write_success "Done."
        ;;
    self-update)
        update_self
        ;;
    self-uninstall)
        uninstall_self "$1"
        ;;
    *)
        write_error "Command '$1' not recognised."
        write_info "See '$0 --help' for available commands."
        ;;
esac