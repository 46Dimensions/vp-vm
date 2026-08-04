#!/usr/bin/env sh

# ANSI colours
red="\033[91m"
green="\033[92m"
yellow="\033[93m"
cyan="\033[96m"
blue="\033[38;5;33m"
purple="\033[38;5;93m"
orange="\033[38;5;208m"
reset="\033[0m"

# Global variables
SCRIPTS_DIR="$HOME/.vp-vm/scripts" # ~/.vp-vm/scripts
MAIN_DIR="$(dirname -- "$SCRIPTS_DIR")" # ~/.vp-vm
DOWNLOAD_DIR="$MAIN_DIR/download" # ~/.vp-vm/download
VERSIONS_DIR="$MAIN_DIR/versions" # ~/.vp-vm/versions

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

mkdir -p "$SCRIPTS_DIR" "$MAIN_DIR" "$DOWNLOAD_DIR" "$VERSIONS_DIR"

write_logo() {
    echo "${purple}🭖█🭀  🭋█🭡   ${orange}██████🭏"
    echo "${purple}🭦█🭐  🭅█🭛   ${orange}██   🭨█"
    echo "${purple} 🭖█🭀🭋█🭡    ${orange}██████🭠"
    echo "${purple} 🭦█🭐🭅█🭛    ${orange}██"
    echo "${purple}  🭖██🭡     ${orange}██${reset}"
    echo "VOCABULARY PLUS"
    echo "Version Manager: macOS & Linux Setup (2.0.0)"
    echo ""
}

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

show_help() {
    echo "Vocabulary Plus Version Manager"
    echo "Usage: $0 [option] [ARGS]"
    echo "Options:"
    echo "  -h --help           show this help message and exit"
    echo "  install VERSION     install a specific version of Vocabulary Plus"
    echo "  list-versions TYPE  list available, installed or current versions."
    echo "                          see '$0 list-versions --help' for help"
    echo "  use VERSION         make VERSION usable"

    exit 0
}

# For stable
: <<'END'
normalise_version() {
    version=$1

    # Remove leading "v"
    case "$version" in
        v*) version=${version#v} ;;
    esac

    # Reject anything that isn't numeric version components
    # and reject anything after the third component.

    case "$version" in
        *[!0-9.]*|*.*.*.*)
            printf ""
            return 1
            ;;
    esac

    major=${version%%.*}
    rest=${version#"$major"}

    case "$rest" in
        .*) rest=${rest#.} ;;
        *)  rest= ;;
    esac

    minor=${rest%%.*}

    if [ "$minor" = "$rest" ]; then
        rest=
    else
        rest=${rest#"$minor."}
    fi

    case "$minor" in
        ''|*[!0-9]*) minor=0 ;;
    esac

    patch=${rest%%.*}

    case "$patch" in
        ''|*[!0-9]*) patch=0 ;;
    esac

    # Validate major
    case "$major" in
        ''|*[!0-9]*)
            return 1
            ;;
    esac

    # Only allow versions >= 2.0.0
    if [ "$major" -lt 2 ]; then
        return 1
    fi

    printf 'v%s.%s.%s\n' "$major" "$minor" "$patch"
}
END

# For testing
normalise_version() {
    version=$1

    if [ "$version" = "latest" ]; then
        list_remote_versions | get_latest_version
    fi

    # Remove leading "v"
    case "$version" in
        v*) version=${version#v} ;;
    esac

    # Extract the major version
    major=${version%%.*}
    rest=${version#"$major"}

    case "$rest" in
        .*) rest=${rest#.} ;;
        *)  rest= ;;
    esac

    # Extract the minor version
    minor=${rest%%.*}

    if [ "$minor" = "$rest" ]; then
        rest=
    else
        rest=${rest#"$minor."}
    fi

    # Validate minor
    case "$minor" in
        ''|*[!0-9]*) minor=0 ;;
    esac

    # Extract patch
    patch=${rest%%-*}

    # Extract optional suffix
    case "$rest" in
        *-*) suffix=${rest#"$patch"} ;;
        *)   suffix= ;;
    esac

    # Validate patch
    case "$patch" in
        ''|*[!0-9]*) patch=0 ;;
    esac

    # Validate major
    case "$major" in
        ''|*[!0-9]*)
            return 1
            ;;
    esac

    # Only allow versions >= 2.0.0
    if [ "$major" -lt 2 ]; then
        return 1
    fi

    # Only allow a -alpha or -beta suffix
    case "$suffix" in
        ''|-alpha*|-beta*) ;;
        *) return 1 ;;
    esac

    printf 'v%s.%s.%s%s\n' "$major" "$minor" "$patch" "$suffix"
}

get_latest_version() {
    latest=

    while IFS= read -r version; do
        if [ -z "$version" ]; then
            continue
        fi

        if [ -z "$latest" ]; then
            latest=$version
            continue
        fi

        # Strip leading v
        a=${version#v}
        b=${latest#v}

        # Extract prerelease suffix
        a_pre=
        b_pre=
        case "$a" in
            *-*) a_pre=${a#*-}; a=${a%%-*} ;;
        esac
        case "$b" in
            *-*) b_pre=${b#*-}; b=${b%%-*} ;;
        esac

        # Split x.y.z
        oldifs=$IFS
        IFS=.
        # shellcheck disable=SC2086
        set -- $a
        a1=$1 a2=$2 a3=$3
        # shellcheck disable=SC2086
        set -- $b
        b1=$1 b2=$2 b3=$3
        IFS=$oldifs

        newer=false

        if [ "$a1" -gt "$b1" ]; then
            newer=true
        elif [ "$a1" -eq "$b1" ]; then
            if [ "$a2" -gt "$b2" ]; then
                newer=true
            elif [ "$a2" -eq "$b2" ]; then
                if [ "$a3" -gt "$b3" ]; then
                    newer=true
                elif [ "$a3" -eq "$b3" ]; then
                    case "$a_pre" in
                        "")      a_rank=3 a_num=0 ;;
                        alpha*)  a_rank=1 a_num=${a_pre#alpha} ;;
                        beta*)   a_rank=2 a_num=${a_pre#beta} ;;
                        *)        a_rank=0 a_num=0 ;;
                    esac
                    case "$b_pre" in
                        "")      b_rank=3 b_num=0 ;;
                        alpha*)  b_rank=1 b_num=${b_pre#alpha} ;;
                        beta*)   b_rank=2 b_num=${b_pre#beta} ;;
                        *)        b_rank=0 b_num=0 ;;
                    esac

                    case "$a_num" in
                        ''|*[!0-9]*) a_num=0 ;;
                    esac
                    case "$b_num" in
                        ''|*[!0-9]*) b_num=0 ;;
                    esac

                    if [ "$a_rank" -gt "$b_rank" ]; then
                        newer=true
                    elif [ "$a_rank" -eq "$b_rank" ] &&
                         [ "$a_num" -gt "$b_num" ]; then
                        newer=true
                    fi
                fi
            fi
        fi

        if $newer; then
            latest=$version
        fi
    done

    printf '%s\n' "$latest"
}

list_remote_versions() {
    curl -fsSL "https://api.github.com/repos/46Dimensions/VocabularyPlus/tags?per_page=100" |
        jq -r '.[].name' |
        while IFS= read -r tag; do
            normalise_version "$tag"
        done

    return 0
}

list_installed_versions() {
    ls "$VERSIONS_DIR"
}

download_version() {
    version="$1"

    echo "Downloading version $version..."
    URL="https://github.com/46Dimensions/VocabularyPlus/releases/download/${version}/VocabularyPlus.zip"
    FILE_PATH="${DOWNLOAD_DIR}/vocabularyplus_${version}.zip"

    curl -fsSL "$URL" -o "$FILE_PATH" || { write_error "Unable to download version $version. Does it exist? "; exit 1; }
}

unpack_zip() {
    zip_file=$1

    if [ -f "$zip_file" ]; then
        basename=$(basename "$zip_file")
        version=${basename#vocabularyplus_}
        version=${version%.zip}

        write_progress "Unpacking ZIP file ${basename} (version $version)..."

        OUTPUT_DIR="$VERSIONS_DIR/$version"
        unzip "$zip_file" -d "$OUTPUT_DIR" || { write_error "Failed to unzip file."; exit 1; }
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

    if [ "$normalised" != "" ]; then
        if ! list_installed_versions | grep -Fq "$normalised"; then
            download_version "$version"
            
            zip_path="${DOWNLOAD_DIR}/vocabularyplus_${version}.zip"

            unpack_zip "$zip_path"
        else
            write_warning "Version $version is already downloaded."

            if [ ! -d "$VERSIONS_DIR/$normalised/installation" ]; then
                write_error "Version $version is already installed."
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

    if [ "$normalised" != "" ]; then
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

use_version() {
    version=$1

    normalised=$(normalise_version "$version")

    if [ "$normalised" != "" ]; then
        VP_DIR="$VERSIONS_DIR/$normalised"

        if [ -s "$VP_DIR/vocabularyplus" ]; then
            write_progress "Setting version $normalised as default..."
            echo "$normalised" > "$MAIN_DIR/current.txt"
            write_success "Set version $version as default."
            write_info "You can now run 'vocabularyplus' to use it."
        else
            write_error "Unable to find version $version."
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

    if [ "$normalised" != "" ]; then
        if list_installed_versions | grep -q "$normalised"; then
            install_confirmation_file="$VERSIONS_DIR/$normalised/installed"
            if [ -f "$install_confirmation_file" ]; then
                return 0
            else
                return 1
            fi
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
        current_version=$(cat "$MAIN_DIR/current.txt")

        remote_versions=$(list_remote_versions)
        latest_version=$(list_remote_versions | get_latest_version)

        count=$(list_installed_versions | grep -c '.')

        echo "VP VM v$VP_VM_VERSION"
        echo ""
        echo "Active version:     $current_version"
        echo "Latest available:   $latest_version"
        echo "Installed versions: $count"
        echo ""
        echo "VP VM directory:    $MAIN_DIR"
        echo "Versions directory: $VERSIONS_DIR"
        echo "Active executable:  $VERSIONS_DIR/$current_version/vocabularyplus"
        echo ""
        echo "Platform:           $PLATFORM ($(uname -m))"
        echo "Shell:              sh"
    else
        normalised=$(normalise_version "$version")

        if [ "$normalised" != "" ]; then
            if check_installed "$normalised"; then
                installed="Yes"
                directory="$VERSIONS_DIR/$normalised"
                executable="$VERSIONS_DIR/$normalised/vocabularyplus"
            else
                installed="No"
                directory="---"
                executable="---"
            fi

            if [ "$(cat "$MAIN_DIR/current")" = "$normalised" ]; then
                active="Yes"
            else
                active="No"
            fi

            echo "VP VM v$VP_VM_VERSION"
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
            echo "$version ✅"
        else
            echo "$version ❌"
        fi
    done
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

    if [ "$latest_version" != "$current_version" ]; then
        write_warning "VP VM does not need updating."
        return 0
    fi

    write_progress "Updating VP VM... (${red}$current_version ${cyan}-> ${green}$latest_version${cyan})"

    INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/46Dimensions/vp-vm/${latest_version}/install.sh"
    INSTALL_SCRIPT_PATH="$DOWNLOAD_DIR/vp-vm-install.sh"

    # download the script
    write_progress "Downloading install script..."
    curl -fsSL "$INSTALL_SCRIPT_URL" -o "$INSTALL_SCRIPT_PATH" || { write_error "Unable to download script"; exit 1; }

    # run the script
    write_progress "Running install script..."
    run_script "$INSTALL_SCRIPT_PATH"

    return 0
}

# Help
HELP_TEXT=$(
cat <<'EOF'
Vocabulary Plus Version Manager

Usage:
    vp-vm <command> [options]

Options:
    -h, --help              Show this help and exit
    -v, --version           Show the current VP VM version

Core Commands:
    install <version>       Install a VocabularyPlus version
    uninstall <version>     Remove a version
    use <version>           Make a version active
    list                    List installed versions
    list-remote             List available versions

Information:
    info [version]          Print information
    where                   Print VP VM directory
    which                   Print location of active executable

Maintenance:
    doctor                  Check that all versions have installed correctly
    cleanup                 Remove temporary files
    update                  Update VP VM
EOF
)

# Validate arguments
case "$1" in
    -h|--help)
        echo "$HELP_TEXT"
        ;;
    -v|--version)
        echo "VP VM $VP_VM_VERSION"
        ;;
    install)
        install_version "$2"
        ;;
    uninstall)
        uninstall_version "$2"
        ;;
    use)
        use_version "$2"
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
        echo "$VERSIONS_DIR/$(cat "$MAIN_DIR/current")/vocabularyplus"
        ;;
    doctor)
        doctor
        ;;
    cleanup)
        write_progress "Clearing downloads..."
        rm -rfv "${DOWNLOAD_DIR:?}"/*
        write_success "Done."
        ;;
    update)
        update_self
        ;;
    *)
        write_error "Command '$1' not recognised."
        echo "See '$0 --help' for available commands."
        ;;
esac