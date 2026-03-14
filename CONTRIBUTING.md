# Contributing to dev-setup

Thanks for contributing. This repository is the orchestration layer for the broader setup, so maintainer notes live here rather than in the user-facing README.

## Development Principles

- Keep `dev-setup` focused on orchestration, not package definitions or dotfile content.
- Prefer changing [cmdtools](https://github.com/tafuru/cmdtools), [dotfiles](https://github.com/tafuru/dotfiles), or [devtools](https://github.com/tafuru/devtools) directly when the change belongs there.
- Keep repo mode and curl mode behavior aligned.
- Keep `README.md` user-facing and move implementation details here.

## Source of Truth

- `setup.sh` is the source of truth for the setup flow and supported options.
- Companion repositories own their respective domains:
  - `cmdtools`: CLI tools
  - `dotfiles`: configuration
  - `devtools`: optional GUI apps and fonts
- Runtime installation is intentionally delegated to `mise install` after dotfiles are applied.

## How to Make Changes

- Add new options only when they change orchestration behavior or repository selection.
- Do not duplicate package lists or dotfile logic in this repository.
- Preserve the ability to run both from a local clone and directly via `curl`.
- If a change affects the interaction between repositories, update the relevant companion repo docs as well.

## Validation

Recommended checks before merging:

```bash
CHEZMOI_GIT_NAME='Test User' \
CHEZMOI_GIT_EMAIL='test@example.com' \
bash setup.sh --repos
```

```bash
CHEZMOI_GIT_NAME='Test User' \
CHEZMOI_GIT_EMAIL='test@example.com' \
bash setup.sh --repos --devtools
```

CI also exercises curl mode after the branch is available on GitHub.

## CI Overview

CI currently validates the following:

- `shellcheck` on `setup.sh`
- `setup.sh` in both repo mode and curl mode on macOS and Ubuntu
- presence of expected CLI tools after setup
- dotfiles application and runtime installation
- Neovim plugin installation and headless startup behavior
- the `--devtools` flow via a mock script

## Repo-Specific Notes

- `--repos` updates or clones repositories under `~/repos/github.com/tafuru/` before using them.
- `setup.sh` is intentionally thin; package manifests and app lists should stay in downstream repositories.
- Neovim plugin sync is part of the setup flow, but deeper Neovim validation belongs in the repositories that own the config and package manifests.
