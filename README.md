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
- `dot clone`: clone repositories
- `dot code`: open repository in Visual Studio Code
- `dot goto`: goto repository directory
- `dot lookup`: open the docs for an oh-my-zsh plugin
- `dot pull`: keep local repositories up-to-date
- `dot reload`: reload dotfiles
- `dot repo`: print repository path
- `dot tm`: time machine utilities for macOS
- `dot update`: update dotfiles from Git
- `dot upgrade`: upgrade installed packages

`clean`, `clone`, `pull`, `update` and `upgrade` also append their output to `~/.dot/dot.log`.
