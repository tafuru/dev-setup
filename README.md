# dev-setup

[![CI](https://github.com/tafuru/dev-setup/actions/workflows/ci.yml/badge.svg)](https://github.com/tafuru/dev-setup/actions/workflows/ci.yml)

Entry point for setting up a new machine.

## Quick Start

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tafuru/dev-setup/main/setup.sh)"
```

Or clone and run:

```bash
git clone https://github.com/tafuru/dev-setup.git
cd dev-setup
bash setup.sh
```

By default, `cmdtools` is installed via curl and `dotfiles` is managed by chezmoi. If `~/repos/github.com/tafuru/cmdtools` or `~/repos/github.com/tafuru/dotfiles` already exist, they are updated in place and used directly.

To clone both repositories under `~/repos/github.com/tafuru/` from scratch and manage them locally:

```bash
bash setup.sh --repos
```

To also install GUI apps and fonts via [devtools](https://github.com/tafuru/devtools):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tafuru/dev-setup/main/setup.sh)" -- --devtools
```

## Using Your Own Dotfiles

If you have forked or created your own dotfiles repository compatible with chezmoi, pass it with `--dotfiles`:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tafuru/dev-setup/main/setup.sh)" -- --dotfiles github.com/yourname/dotfiles
```

## What It Does

`setup.sh` runs the following in order:

1. **[cmdtools](https://github.com/tafuru/cmdtools)** — Install CLI tools via Homebrew (macOS) or apt + GitHub Releases (Linux)
2. **[dotfiles](https://github.com/tafuru/dotfiles)** — Apply configuration files via chezmoi
3. **mise install** — Install runtimes defined in `~/.config/mise/config.toml` (Rust, Node.js, Python, etc.)
4. **[devtools](https://github.com/tafuru/devtools)** *(optional, `--devtools`)* — Install GUI apps and fonts

## Repository Structure

| Repository | Responsibility |
|---|---|
| [dev-setup](https://github.com/tafuru/dev-setup) | Setup entry point (this repository) |
| [cmdtools](https://github.com/tafuru/cmdtools) | CLI tool installation |
| [dotfiles](https://github.com/tafuru/dotfiles) | Configuration file management (chezmoi) |
| [devtools](https://github.com/tafuru/devtools) | GUI apps and fonts (optional) |

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE) for details.
