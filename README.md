# Vocabulary Plus Version Manager (`vp-vm`)

![The Vocabulary Plus logo with the words 'Vocabulary Plus Version Manager' to the right of it](https://raw.githubusercontent.com/46Dimensions/vp-vm/v1.2.4/readme_logo.png)

This repository is where [46Dimensions](https://github.com/46Dimensions)
develops [Vocabulary Plus](https://github.com/46Dimensions/VocabularyPlus)'s version manager (`vp-vm`).

Vocabulary Plus Version Manager is a program which can be used to install and manage multiple Vocabulary Plus versions side-by-side.

## Installation

To install VP VM, download and run the installation script.

### Windows

Run in **Windows Terminal** > **PowerShell**

``` powershell
# Download the installation script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/46Dimensions/vp-vm/2.0.0/install.ps1" -OutFile ".\install.ps1"

# Run the script then remove it
& .\install.ps1
Remove-Item -Force -Path .\install.ps1
```

### MacOS/Linux

Run in **Terminal** (name may vary)

``` sh
curl -fsSL "https://raw.githubusercontent.com/46Dimensions/vp-vm/2.0.0/install.sh" | sh
```

## Commands

Usage: `vp-vm <command> [options]`

### Options

* `-h, --help` — Show this help message and exit
* `-v, --version` — Show VP VM version and exit

### Core Commands

* `install <version>` — Install a Vocabulary Plus version
* `uninstall <version>` — Uninstall a version
* `use <version>` — Make a version active
* `list` — List installed versions
* `list-remote` — List available versions

### Information

* `info [version]` — Show information about a version
* `where` — Show the VP VM directory
* `which` — Show the location of the active executable

### Maintenance

* `doctor` — Check that all versions are installed correctly
* `cleanup` — Remove temporary files
* `self-update` — Update VP VM
* `self-uninstall [--yes]` — Uninstall VP VM and all Vocabulary Plus versions

  * `--yes` — Skip confirmation


## Issues

Report bugs in [this repository's Issues](https://github.com/46Dimensions/vp-vm/issues), **not in VocabularyPlus.**

## License

The source code is licensed under the MIT license.  
See [LICENSE](LICENSE) for details.
