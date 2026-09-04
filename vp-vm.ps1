$esc = [char]27
$red = "$esc[31m"
$cyan = "$esc[36m"
$green = "$esc[32m"
$purple = "$esc[38;5;93m"
$orange = "$esc[38;5;208m"
$reset = "$esc[0m"

function Write-Colour {
    param(
        [string]$Text,
        [System.ConsoleColor]$Colour
    )

    if (-not $Silent) {
        Write-Host $text -ForegroundColor $colour
    }
}

function Test-FileNotEmpty {
    param([string]$Path)

    (Test-Path $Path -PathType Leaf) -and (Get-Item $Path).Length -gt 0
}

# Global variables
$MAIN_DIR = Join-Path $HOME ".vp-vm"
$DOWNLOAD_DIR = Join-Path "$MAIN_DIR" "download"
$VERSIONS_DIR = Join-Path "$MAIN_DIR" "versions"

$VP_VM_VERSION = Get-Content (Join-Path $MAIN_DIR "version.txt")
$WINDOWS_VERSION = (Get-ComputerInfo -Property WindowsDisplayVersion).WindowsDisplayVersion

New-Item -ItemType Directory -Path $MAIN_DIR -Force | Out-Null
New-Item -ItemType Directory -Path $DOWNLOAD_DIR -Force | Out-Null
New-Item -ItemType Directory -Path $VERSIONS_DIR -Force | Out-Null

function Write-Logo {
    Write-Host "${purple}🭖█🭀  🭋█🭡   ${orange}██████🭏"
    Write-Host "${purple}🭦█🭐  🭅█🭛   ${orange}██   🭨█"
    Write-Host "${purple} 🭖█🭀🭋█🭡    ${orange}██████🭠"
    Write-Host "${purple} 🭦█🭐🭅█🭛    ${orange}██"
    Write-Host "${purple}  🭖██🭡     ${orange}██${reset}"
    Write-Host "VOCABULARY PLUS"
    Write-Host "Version Manager for Windows (2.0.0 Beta 1)"
    Write-Host ""
}

function Convert-ToNormalizedVersion {
    param([string]$version)

    if ($version -eq "latest") {
        $version = list_remote_versions | get_latest_version
    }

    $version = $version.TrimStart('v')
    $parts = $version -split '\.', 3

    $major = $parts[0]
    $minor = if ($parts.Count -gt 1) { $parts[1] } else { '' }
    $rest = if ($parts.Count -gt 2) { $parts[2] } else { '' }

    if ($minor -notmatch '^\d+$') { $minor = '0' }

    $patch = $rest -replace '-.*', ''
    $suffix = if ($rest -match '-.*') { $Matches[0] } else { '' }

    if ($patch -notmatch '^\d+$') { $patch = '0' }
    if ($major -notmatch '^\d+$') { return }
    if ([int]$major -lt 2) { return }
    if ($suffix -notmatch '^-(alpha|beta)' -and $suffix) { return }

    "v$major.$minor.$patch$suffix"
}

function Select-LatestVersion {
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Version
    )

    begin {
        $latest = $null

        function Get-Rank($Pre) {
            if (!$Pre) { return 3 }
            if ($Pre -match '^alpha\d*$') { return 1 }
            if ($Pre -match '^beta\d*$') { return 2 }

            throw "Unknown version suffix: -$Pre"
        }

        function Get-Number($Pre) {
            if ($Pre -match '^[a-z]+(\d+)$') {
                return [int]$Matches[1]
            }
            return 0
        }
    }

    process {
        if (!$Version) { return }

        if (!$latest) {
            $latest = $Version
            return
        }

        $v = $Version.TrimStart('v')
        $l = $latest.TrimStart('v')

        $vp, $vpre = $v -split '-', 2
        $lp, $lpre = $l -split '-', 2

        $vn = $vp -split '\.'
        $ln = $lp -split '\.'

        $newer = $false

        foreach ($i in 0..2) {
            if ([int]$vn[$i] -ne [int]$ln[$i]) {
                $newer = [int]$vn[$i] -gt [int]$ln[$i]
                break
            }
        }

        if ($vn[0] -eq $ln[0] -and $vn[1] -eq $ln[1] -and $vn[2] -eq $ln[2]) {
            $vr = Get-Rank $vpre
            $lr = Get-Rank $lpre

            $newer = $vr -gt $lr -or
            ($vr -eq $lr -and (Get-Number $vpre) -gt (Get-Number $lpre))
        }

        if ($newer) {
            $latest = $Version
        }
    }

    end {
        $latest
    }
}

function Get-RemoteVersions {
    (Invoke-RestMethod "https://api.github.com/repos/46Dimensions/VocabularyPlus/tags?per_page=100").name |
    ForEach-Object { Convert-ToNormalizedVersion $_ }
}

function Get-InstalledVersions {
    Get-ChildItem $VERSIONS_DIR -Name
}

function Save-Version {
    param(
        [String]$Version
    )

    $normalised = Convert-ToNormalizedVersion

    if ($normalised) {
        Write-Colour "Downloading version $Normalised..." Cyan
        $URL = "https://github.com/46Dimensions/VocabularyPlus/releases/download/${normalised}/VocabularyPlus.zip"
        $file_path = Join-Path $DOWNLOAD_DIR "vocabularyplus_$normalised.zip"

        try {
            Invoke-WebRequest -Uri $URL -OutFile $file_path

            if ($LASTEXITCODE -ne 0) {
                throw "Command failed with exit code $LASTEXITCODE"
            }
        }
        catch {
            Write-Error "Unable to download version $normalised. Does it exist?"
        }
    }
    else {
        Write-Error "Version $version is invalid or does not exist."
        exit 1
    }
}

function Expand-Zip {
    param(
        [String]$Path
    )

    if (Test-Path $Path) {
        $basename = Split-Path $zipFile -Leaf
        $version = $basename -replace '^vocabularyplus_', ''
        $version = $version -replace '\.zip$', ''

        Write-Colour "Unpacking ZIP file $basename (version $version)..." Cyan

        $OUTPUT_DIR = Join-Path $VERSIONS_DIR $version
        Expand-Archive -Path $zip_file -DestinationPath $OUTPUT_DIR
    }
    else {
        Write-Error "ZIP file not found $zip_file"
        return 1
    }
}

function Invoke-Script {
    param(
        [String]$Path
    )

    $executable = (Get-Process -Id $PID).Path
    & $executable $Path
}

function Install-Version {
    param(
        [String]$Version
    )

    $normalised = Convert-ToNormalizedVersion $Version

    if ($normalised) {
        if (list_installed_versions | Where-Object { $_ -eq $normalised }) {
            Save-Version $normalised

            $zip_path = Join-Path "$DOWNLOAD_DIR" "vocabularyplus_$normalised.zip}"

            Expand-Zip $zip_path
        }
        else {
            Write-Warning "Version $normalised is already downloaded."

            if (-not (Test-Path "$(Join-Path $VERSIONS_DIR $normalised "installation")")) {
                Write-Error "Version $normalised is already installed."
                exit 1
            }
        }
    }
    else {
        Write-Error "Invalid version: '$version'"
        exit 1
    }
}

function Uninstall-Version {
    param(
        [String]$Version
    )

    $normalised = Convert-ToNormalizedVersion $Version

    if ($normalised) {
        $VP_DIR = Join-Path $VERSIONS_DIR $normalised
        
        if (Test-FileNotEmpty (Join-Path $VP_DIR "uninstall.ps1")) {
            Write-Colour "Uninstalling $normalised..." Cyan
            Invoke-Script (Join-Path $VP_DIR "uninstall.ps1")

            if (Test-Path $VP_DIR) {
                Write-Colour "Removing directory..." Cyan
                Remove-Item -Recurse $VP_DIR
            }
            Write-Colour "Successfully uninstalled Vocabulary Plus $normalised." Green
        }
        else {
            Write-Error "Invalid version: '$version'"
        }
    }
}

function Set-DefaultVersion {
    param(
        [String]$Version
    )

    $normalised = Convert-ToNormalizedVersion $Version

    if ($normalised) {
        $VP_DIR = Join-Path $VERSIONS_DIR $normalised

        if (Test-FileNotEmpty (Join-Path $VP_DIR "vocabularyplus")) {
            Write-Colour "Setting version $normalised as default..." Cyan
            Set-Content -Path (Join-Path $MAIN_DIR "current.txt") -Value $normalised
            Write-Colour "Set version $version as default." Green
            Write-Colour "You can now run 'vocabularyplus' to use it." Blue
        }
        else {
            Write-Error "Unable to find version $normalised"
            exit 1
        }
    }
    else {
        Write-Error "Invalid version: $Version"
        exit 1
    }
}

function Test-VersionInstalled {
    param(
        [String]$Version
    )

    $normalised = Convert-ToNormalizedVersion $Version

    if ($normalised) {
        if (list_installed_versions | Where-Object { $_ -eq $normalised }) {
            return (Test-Path (Join-Path $VERSIONS_DIR $normalised "installation"))
        }
        else {
            return $false
        }
    }
    else {
        Write-Error "Invalid version: $Version"
        return $false
    }
}

function Show-Info {
    param(
        [String]$Version
    )

    if (-not $Version) {
        if (Test-FileNotEmpty (Join-Path $MAIN_DIR "current.txt")) {
            $current_version = Get-Content (Join-Path $MAIN_DIR "current.txt")
            $active_executable = Get-Content (Join-Path $VERSIONS_DIR $current_version "vocabularyplus")
        }
        else {
            $current_version = "---"
            $active_executable = "---"
        }

        $latest_version = Get-RemoteVersions | Select-LatestVersion
        $count = @(Get-InstalledVersions).Count

        Write-Host "VP VM v$VP_VM_VERSION"
        Write-Host ""
        Write-Host "Active version:     $current_version"
        Write-Host "Latest available:   $latest_version"
        Write-Host "Installed versions: $count"
        Write-Host ""
        Write-Host "VP VM directory:    $MAIN_DIR"
        Write-Host "Versions directory: $VERSIONS_DIR"
        Write-Host "Active executable:  $active_executable"
        Write-Host ""
        Write-Host "Platform:           $WINDOWS_VERSION"
        Write-Host "Shell:              PowerShell $($PSVersionTable.PSVersion)"
    }
    else {
        $normalised = Convert-ToNormalizedVersion $Version

        if ($normalised) {
            if (Test-VersionInstalled $normalised) {
                $installed = "Yes"
                $directory = Join-Path $VERSIONS_DIR $normalised
                $executable = Join-Path $directory "vocabularyplus"
            }
            else {
                $installed = "No"
                $directory = "---"
                $executable = "---"
            }

            if ((Get-Content (Join-Path $MAIN_DIR "current.txt")) -eq $normalised) {
                $active = "Yes"
            }
            else {
                $active = "No"
            }

            Write-Host "VP VM v$VP_VM_VERSION"
            Write-Host ""
            Write-Host "Version: $normalised"
            Write-Host "Installed: $installed"
            Write-Host "Active: $active"
            Write-Host "Directory: $directory"
            Write-Host "Executable: $executable"
        }
        else {
            Write-Error "Invalid version: '$Version'"
            exit 1
        }
    }
}

function Test-Versions {
    Write-Colour "Checking versions..." Cyan

    Get-InstalledVersions | ForEach-Object {
        $version = $_

        if (Test-VersionInstalled $version) {
            "$version ✅"
        }
        else {
            "$version ❌"
        }
    }
}

function Update-Self {
    function Get-Versions {
        (Invoke-RestMethod "https://api.github.com/repos/46Dimensions/vp-vm/tags?per_page=100").name |
        ForEach-Object { Convert-ToNormalizedVersion $_ }
    }

    $latest_version = Get-Versions | Select-LatestVersion
    $current_version = $VP_VM_VERSION

    if ($latest_version -eq $current_version) {
        Write-Colour "VP VM is already the latest version ($VP_VM_VERSION)" Blue
        exit 0
    }

    Write-Host "${cyan}Updating VP VM... (${red}$current_version ${cyan}-> ${green}$latest_version${cyan})${reset}"

    $install_script_url = "https://raw.githubusercontent.com/46Dimensions/vp-vm/${latest_version}/install.sh"
    $install_script_path = Join-Path $DOWNLOAD_DIR "vp-vm-install.sh"
    
    # Download the script
    Write-Colour "Downloading install script..." Cyan
    Invoke-WebRequest -Uri $install_script_url -OutFile $install_script_path -ErrorAction Stop

    # Run the script
    Write-Colour "Running install script..." Cyan
    Invoke-Script $install_script_path
}

# Help
$help_text = @"
Vocabulary Plus Version Manager

Usage:
    vp-vm <command> [options]

Options:
    -h, --help              Show this help and exit
    -v, --version           Show the current VP VM version and exit

Core Commands:
    install <version>       Install a VocabularyPlus version
    uninstall <version>     Remove a version
    use <version>           Make a version active
    list                    List installed versions
    list-remote             List available versions

Information:
    info [version]          Print information, optionally about [version]
    where                   Print VP VM directory
    which                   Print location of active executable

Maintenance:
    doctor                  Check that all versions have installed correctly
    cleanup                 Remove temporary files
    update                  Update VP VM
"@

Write-Logo

# Handle arguments
switch ($args[0]) {
    { $_ -in '-h', '--help' } {
        Write-Host $help_text
    }
    { $_ -in '-v', '--version' } {
        Write-Host "Vocabulary Plus Version Manager v$VP_VM_VERSION"
    }
    'install' {
        Install-Version $args[1]
    }
    'uninstall' {
        Uninstall-Version $args[1]
    }
    'use' {
        Set-DefaultVersion $args[1]
    }
    { $_ -in 'list', 'ls' } {
        Write-Colour "Installed versions:" Blue
        Get-InstalledVersions
    }
    { $_ -in 'list-remote', 'ls-remote' } {
        Write-Colour "Available versions:" Blue
        Get-RemoteVersions
    }
    'info' {
        Show-Info $args[1]
    }
    'where' {
        Write-Output $MAIN_DIR
    }
    'which' {
        Write-Output (Join-Path $VERSIONS_DIR (Get-Content (Join-Path $MAIN_DIR "current.txt")) "vocabularyplus")
    }
    'doctor' {
        Test-Versions
    }
    'cleanup' {
        Write-Colour "Clearing downloads..." Cyan
        if (-not $DOWNLOAD_DIR) {
            throw 'DOWNLOAD_DIR is not set'
        }

        Remove-Item "$DOWNLOAD_DIR\*" -Recurse -Force
        Write-Colour "Done." Green
    }
    'update' {
        Update-Self
    }
    default {
        Write-Error "Command '$($args[0])' not recognised."
        Write-Colour "See '$($MyInvocation.MyCommand.Name) --help' for available commands."
    }
}