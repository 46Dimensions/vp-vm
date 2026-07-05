# Vocabulary Plus Version Manager (`vp-vm`)

![The Vocabulary Plus logo with the words 'Vocabulary Plus Version Manager' to the right of it](https://raw.githubusercontent.com/46Dimensions/vp-vm/1.2.0/readme_logo.png)

This repository is where [46Dimensions](github.com/46Dimensions) develops [Vocabulary Plus](https://github.com/46Dimensions/VocabularyPlus)'s version manager (`vp-vm`).

Vocabulary Plus Version Manager is a program which can be used to upgrade Vocabulary Plus to the latest version without losing your vocabulary files. It will also upgrade itself if necessary.

## Installation

Vocabulary Plus Version Manager is available on macOS, Linux and Windows in version [`1.3.0`](https://github.com/46Dimensions/VocabularyPlus/tree/1.3.0) or later of [Vocabulary Plus](https://github.com/46Dimensions/VocabularyPlus).  

See [VocabularyPlus's README](https://github.com/46Dimensions/VocabularyPlus/blob/main/README.md) for installation instructions.

## Running

Once installed, you can run:

- `vp-vm --help` to show all available commands
- `vp-vm update` to update the package lists
- `vp-vm upgrade` to upgrade Vocabulary Plus and Vocabulary Plus Version Manager if necessary
- `vp-vm list-upgradable` to see upgradable packages
- `vp-vm install-version [version]` to install a specific version of Vocabulary Plus. See "The `install-version` command" below
- `vp-vm --version` to see the currently installed version of `vp-vm`

## The `install-version` command

The `install-version` command installs a specific version of VocabularyPlus.
The `[version]` argument comes after `vp-vm install-version` - set it to the version you want to install.

> [!NOTE]
> This command cannot install versions 1.2.0-1.4.0 because they
> supply URLs linking to the current version.
> This is a problem because the `app_icon.png` file has been deleted in version 1.5.0.  
> The problem will not occur in versions `1.5.1` onwards.

## Issues

Report bugs in [this repository's Issues](https://github.com/46Dimensions/vp-vm/issues), **not in VocabularyPlus.**

## License

The source code is licensed under the MIT license.  
See [LICENSE](LICENSE) for details.
