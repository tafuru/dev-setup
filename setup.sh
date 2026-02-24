#!/usr/bin/env bash
set -euo pipefail

GITHUB_USER="tafuru"
REPOS_DIR="$HOME/repos/github.com/$GITHUB_USER"
REPOS=false

info()    { echo "[dev-setup] $*"; }
success() { echo "[dev-setup] ✓ $*"; }
warn()    { echo "[dev-setup] ! $*" >&2; }
fatal()   { echo "[dev-setup] ✗ $*" >&2; exit 1; }

for arg in "$@"; do
  case "$arg" in
    --repos) REPOS=true ;;
  esac
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

# [1/2] CLI tools
info "[1/2] Installing CLI tools"
if [ "$REPOS" = true ] || [ -d "$REPOS_DIR/cmdtools" ]; then
  clone_or_update cmdtools
  bash "$REPOS_DIR/cmdtools/install.sh"
else
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/$GITHUB_USER/cmdtools/main/install.sh)"
fi
success "[1/2] CLI tools installed"

# Ensure chezmoi (installed to ~/.local/bin on Linux by cmdtools) is in PATH
export PATH="$HOME/.local/bin:$PATH"

# [2/2] Dotfiles
info "[2/2] Applying dotfiles"
if [ "$REPOS" = true ] || [ -d "$REPOS_DIR/dotfiles" ]; then
  clone_or_update dotfiles
  chezmoi init --apply --source "$REPOS_DIR/dotfiles/home"
elif [ -d "$(chezmoi source-path 2>/dev/null)" ]; then
  chezmoi apply
else
  chezmoi init --apply "github.com/$GITHUB_USER/dotfiles"
fi
success "[2/2] Dotfiles applied"

echo ""
success "Setup complete — restart your shell to apply changes"
