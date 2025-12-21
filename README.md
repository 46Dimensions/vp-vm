# Vocabulary Plus Version Manager (`vp-vm`)

<img src="/readme_logo.png" alt="The Vocabulary Plus Version Manager Logo" height="600">

This repository is where [46Dimensions](github.com/46Dimensions) develops [Vocabulary Plus](https://github.com/46Dimensions/VocabularyPlus)'s version manager (`vp-vm`).

Vocabulary Plus Version Manager is a program which can be used to upgrade Vocabulary Plus to the latest version without losing your vocabulary files. It will also upgrade itself if necessary.

> [!NOTE]  
> Vocabulary Plus Version Manager is under development.  
> It must only be used as part of Vocabulary Plus.  
> The integration with Vocabulary Plus is not yet complete; please report problems on the [Issues](https://github.com/46Dimensions/vp-vm/issues) page.

## Installation

Vocabulary Plus Version Manager is available on macOS and Linux in the [`vp-vm`](https://github.com/46Dimensions/VocabularyPlus/tree/vp-vm) branch in [Vocabulary Plus](https://github.com/46Dimensions/VocabularyPlus/).  
You can install it with:

``` shell
curl -fsSL https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/vp-vm/install.sh | sh
```

It is not currently available on Windows.

## Running

Once installed, you can run:

- `vp-vm --help` to show all available commands
- `vp-vm update` to update the package lists
- `vp-vm upgrade` to upgrade Vocabulary Plus and Vocabulary Plus Version Manager if necessary
- `vp-vm list-upgradable` to see upgradable packages
- `vp-vm --version` to see the currently installed version of `vp-vm`

## Issues

Report bugs in this repository's [Issues](https://github.com/46Dimensions/vp-vm/issues), **not in VocabularyPlus.**

## License

This source code is licensed under the MIT license.  
See [LICENSE](LICENSE) for details.
