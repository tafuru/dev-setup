#!/usr/bin/env bash
set -euo pipefail

GITHUB_USER="tafuru"
REPOS_DIR="$HOME/repos/github.com/$GITHUB_USER"
DOTFILES_REPO="github.com/$GITHUB_USER/dotfiles"
REPOS=false

info()    { echo "[dev-setup] $*"; }
success() { echo "[dev-setup] ✓ $*"; }
warn()    { echo "[dev-setup] ! $*" >&2; }
fatal()   { echo "[dev-setup] ✗ $*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --repos)     REPOS=true ;;
    --dotfiles)  shift; DOTFILES_REPO="$1" ;;
    *)           fatal "Unknown option: $1" ;;
  esac
  shift
done

clone_or_update() {
  local repo="$1"
  local dir="$REPOS_DIR/$repo"
  if [ -d "$dir/.git" ]; then
    info "Updating $repo"
    git -C "$dir" fetch --quiet origin
    git -C "$dir" reset --hard origin/main
  else
    info "Cloning $repo"
    mkdir -p "$REPOS_DIR"
    git clone "https://github.com/$GITHUB_USER/$repo.git" "$dir"
  fi
}

# [1/3] CLI tools
info "[1/3] Installing CLI tools"
if [ "$REPOS" = true ] || [ -d "$REPOS_DIR/cmdtools" ]; then
  clone_or_update cmdtools
  bash "$REPOS_DIR/cmdtools/install.sh"
else
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/$GITHUB_USER/cmdtools/main/install.sh)"
fi
success "[1/3] CLI tools installed"

# Ensure chezmoi (installed to ~/.local/bin on Linux by cmdtools) is in PATH
export PATH="$HOME/.local/bin:$PATH"

# [2/3] Dotfiles
info "[2/3] Applying dotfiles"
DOTFILES_GH_PATH="${DOTFILES_REPO#github.com/}"
DOTFILES_DIR="$HOME/repos/github.com/$DOTFILES_GH_PATH"
if [ "$REPOS" = true ] || [ -d "$DOTFILES_DIR" ]; then
  if [ -d "$DOTFILES_DIR/.git" ]; then
    info "Updating dotfiles"
    git -C "$DOTFILES_DIR" fetch --quiet origin
    git -C "$DOTFILES_DIR" reset --hard origin/main
  else
    info "Cloning dotfiles"
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    git clone "https://github.com/$DOTFILES_GH_PATH.git" "$DOTFILES_DIR"
  fi
  chezmoi init --apply --source "$DOTFILES_DIR/home"
elif [ -d "$(chezmoi source-path 2>/dev/null)" ]; then
  chezmoi apply
else
  chezmoi init --apply "$DOTFILES_REPO"
fi
success "[2/3] Dotfiles applied"

# [3/3] Runtimes
info "[3/3] Installing runtimes via mise"
mise install
success "[3/3] Runtimes installed"

echo ""
success "Setup complete — restart your shell to apply changes"
