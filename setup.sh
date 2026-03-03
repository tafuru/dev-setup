#!/usr/bin/env bash
set -euo pipefail

GITHUB_USER="tafuru"
REPOS_DIR="$HOME/repos/github.com/$GITHUB_USER"
DOTFILES_REPO="github.com/$GITHUB_USER/dotfiles"
REPOS=false
DEVTOOLS=false

info()    { echo "[dev-setup] $*"; }
success() { echo "[dev-setup] ✓ $*"; }
warn()    { echo "[dev-setup] ! $*" >&2; }
fatal()   { echo "[dev-setup] ✗ $*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --repos)     REPOS=true ;;
    --dotfiles)  shift; DOTFILES_REPO="$1" ;;
    --devtools)  DEVTOOLS=true ;;
    --help)
      echo "Usage: setup.sh [options]"
      echo ""
      echo "Options:"
      echo "  --repos              Clone all repos to ~/repos/github.com/tafuru/"
      echo "  --dotfiles <repo>    Use a custom dotfiles repo (default: github.com/tafuru/dotfiles)"
      echo "  --devtools           Install GUI apps and fonts via devtools"
      echo "  --help               Show this help"
      exit 0 ;;
    *)           fatal "Unknown option: $1" ;;
  esac
  shift
done

TOTAL_STEPS=4
[ "$DEVTOOLS" = true ] && TOTAL_STEPS=5

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

# Clone dev-setup itself when --repos is requested (curl mode leaves no local copy)
if [ "$REPOS" = true ]; then
  clone_or_update dev-setup
fi

# [1/5] CLI tools
info "[1/${TOTAL_STEPS}] Installing CLI tools"
if [ "$REPOS" = true ] || [ -d "$REPOS_DIR/cmdtools" ]; then
  clone_or_update cmdtools
  bash "$REPOS_DIR/cmdtools/install.sh"
else
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/$GITHUB_USER/cmdtools/main/install.sh)"
fi
success "[1/${TOTAL_STEPS}] CLI tools installed"

# Ensure tools installed via Linuxbrew are in PATH for subsequent steps
[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# [2/5] Dotfiles
info "[2/${TOTAL_STEPS}] Applying dotfiles"
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
success "[2/${TOTAL_STEPS}] Dotfiles applied"

# [3/5] Runtimes
info "[3/${TOTAL_STEPS}] Installing runtimes via mise"
mise install
success "[3/${TOTAL_STEPS}] Runtimes installed"

# [4/5] Neovim plugins
info "[4/${TOTAL_STEPS}] Syncing Neovim plugins"
if command -v nvim >/dev/null 2>&1; then
  nvim --headless '+Lazy! sync' +qa 2>&1 || warn "Neovim plugin sync encountered an issue"
  success "[4/${TOTAL_STEPS}] Neovim plugins synced"
else
  warn "[4/${TOTAL_STEPS}] nvim not found — skipping plugin sync"
fi

# [5/5] GUI apps and fonts (optional)
if [ "$DEVTOOLS" = true ]; then
  info "[5/${TOTAL_STEPS}] Installing GUI apps and fonts"
  if [ -n "${DEVTOOLS_SCRIPT:-}" ]; then
    bash "$DEVTOOLS_SCRIPT"
  elif [ "$REPOS" = true ] || [ -d "$REPOS_DIR/devtools" ]; then
    clone_or_update devtools
    bash "$REPOS_DIR/devtools/install.sh"
  else
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/$GITHUB_USER/devtools/main/install.sh)"
  fi
  success "[5/${TOTAL_STEPS}] GUI apps and fonts installed"
fi

echo ""
success "Setup complete — restart your shell to apply changes"
