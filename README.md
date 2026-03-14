# dev-setup

[![CI](https://github.com/tafuru/dev-setup/actions/workflows/ci.yml/badge.svg)](https://github.com/tafuru/dev-setup/actions/workflows/ci.yml)

Set up a new development machine for macOS or Ubuntu/Debian. This repository is the entry point for the full environment: CLI tools, dotfiles, runtimes via `mise`, Neovim plugins, and optional GUI apps and fonts.

## Quick Start

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tafuru/dev-setup/main/setup.sh)"
```

Or clone and run it locally:

```bash
git clone https://github.com/tafuru/dev-setup.git
cd dev-setup
bash setup.sh
```

If matching repositories already exist under `~/repos/github.com/tafuru/`, `setup.sh` updates them in place and reuses them.

## When to Use This Repository

- Use this repository when you want the full machine setup.
- Use [cmdtools](https://github.com/tafuru/cmdtools), [dotfiles](https://github.com/tafuru/dotfiles), or [devtools](https://github.com/tafuru/devtools) directly only when you want a single layer on its own.

## Options

| Option | Description |
|---|---|
| `--repos` | Clone or update the companion repositories under `~/repos/github.com/tafuru/` and use them directly |
| `--dotfiles <repo>` | Use a custom chezmoi-compatible dotfiles repository instead of `github.com/tafuru/dotfiles` |
| `--devtools` | Install optional GUI apps and fonts via [devtools](https://github.com/tafuru/devtools) |
| `--help` | Show usage information |

Examples:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tafuru/dev-setup/main/setup.sh)" -- --repos
```

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tafuru/dev-setup/main/setup.sh)" -- --dotfiles github.com/yourname/dotfiles
```

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tafuru/dev-setup/main/setup.sh)" -- --devtools
```

## What It Does

`setup.sh` runs the following steps in order:

1. Install CLI tools via [cmdtools](https://github.com/tafuru/cmdtools)
2. Apply configuration via [dotfiles](https://github.com/tafuru/dotfiles)
3. Run `mise install` for runtimes defined in `~/.config/mise/config.toml`
4. Sync Neovim plugins when `nvim` is available
5. Optionally install GUI apps and fonts via [devtools](https://github.com/tafuru/devtools)

## Repository Responsibilities

| Repository | Responsibility |
|---|---|
| [dev-setup](https://github.com/tafuru/dev-setup) | Full machine setup and orchestration |
| [cmdtools](https://github.com/tafuru/cmdtools) | CLI tool installation |
| [dotfiles](https://github.com/tafuru/dotfiles) | Configuration management with chezmoi |
| [devtools](https://github.com/tafuru/devtools) | Optional GUI apps and fonts |

## Platform Notes

- On macOS, the companion repositories install tools and apps through Homebrew.
- On Ubuntu/Debian, CLI setup uses apt plus Homebrew where needed, and GUI apps are handled separately by `devtools`.
- `mise` runtime definitions come from the applied dotfiles, so the configuration layer stays separate from the setup orchestration.

## Contributing

README stays focused on how to use the full setup. For CI behavior, validation steps, and repository maintenance guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE) for details.
