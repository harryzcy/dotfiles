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

- dot clean
- dot update
