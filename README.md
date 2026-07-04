# Vocabulary Plus Version Manager (`vp-vm`)

![The Vocabulary Plus logo with the words 'Vocabulary Plus Version Manager' to the right of it](https://raw.githubusercontent.com/46Dimensions/vp-vm/1.1.0/readme_logo.png)

This repository is where [46Dimensions](github.com/46Dimensions) develops [Vocabulary Plus](https://github.com/46Dimensions/VocabularyPlus)'s version manager (`vp-vm`).

Vocabulary Plus Version Manager is a program which can be used to upgrade Vocabulary Plus to the latest version without losing your vocabulary files. It will also upgrade itself if necessary.

## Installation

Vocabulary Plus Version Manager is available on macOS, Linux and Windows in version [`1.3.0`](https://github.com/46Dimensions/VocabularyPlus/tree/1.3.0) or later of [Vocabulary Plus](https://github.com/46Dimensions/VocabularyPlus).  
You can install it on macOS/Linux with:

``` shell
curl -fsSL https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/v1.3.0/install.sh | sh
```

Or on Windows:

``` batch
curl -fsSL https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/v1.3.0/install.bat -o install.bat
call install.bat
```

## Running

Once installed, you can run:

- `vp-vm --help` to show all available commands
- `vp-vm update` to update the package lists
- `vp-vm upgrade` to upgrade Vocabulary Plus and Vocabulary Plus Version Manager if necessary
- `vp-vm list-upgradable` to see upgradable packages
- `vp-vm --version` to see the currently installed version of `vp-vm`

## Issues

Report bugs in [this repository's Issues](https://github.com/46Dimensions/vp-vm/issues), **not in VocabularyPlus.**

## License

The source code is licensed under the MIT license.  
See [LICENSE](LICENSE) for details.
