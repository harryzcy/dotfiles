# dotfiles

[![Dotfiles Test](https://github.com/harryzcy/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/harryzcy/dotfiles/actions/workflows/ci.yml)

## Structure

|  directory  | description |
| ----------- | ----------- |
| **codespace** | config files for GitHub codespaces |
| **dev**     | config files for dev machines |
| **dot**     | `dot` commands |
| **macos**   | config files for macOS, also imports `dev` |
| **linux**   | config files for Linux machines, optionally imports `dev` |
| **script**  | command script used by `make` targets and `dot` commands |
| **test**    | test scripts used by `make test` |

## Dot commands

`dot` is the entry command for many scripts.

- `dot clean`: cleanup cache
- `dot update`: update dotfiles from Git
- `dot upgrade`: upgrade installed packages
- `dot reload`: reload dotfiles
- `dot repo`: print repository path
- `dot goto`: goto repository directory
- `dot code`: open repository in Visual Studio Code
- `dot tm`: time machine utilities for macOS
- `dot pull`: keep local repositories up-to-date
