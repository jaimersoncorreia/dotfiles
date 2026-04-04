#!/bin/bash

# Configuration
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${DEST_DIR:-$HOME}"
DRY_RUN=0

# Parse arguments
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
  esac
done

# Helper functions
log() {
  echo -e "\033[1;34m[INFO]\033[0m $1"
}

warn() {
  echo -e "\033[1;33m[WARN]\033[0m $1"
}

error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1"
}

execute() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo -e "\033[1;36m[DRY-RUN]\033[0m Would execute: $1"
  else
    eval "$1"
  fi
}

log "Starting macOS Terminal Setup..."
if [ "$DRY_RUN" -eq 1 ]; then
  log "Running in DRY-RUN mode. No changes will be made."
fi

# 1. Install Homebrew
if ! command -v brew &> /dev/null; then
  log "Homebrew not found. Installing Homebrew..."
  execute '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  
  # Ensure Homebrew is in the path for the rest of the script (Apple Silicon & Intel)
  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  log "Homebrew is already installed."
  # Ensure Homebrew is in the path for the current session if not already
  if [ -f /opt/homebrew/bin/brew ] && ! command -v brew &> /dev/null; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

# Nerd Font Warning for Apple Terminal
if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
  warn "You are using Apple Terminal. Commands like 'ls' (aliased to 'eza') may show broken symbols unless you install a Nerd Font (e.g., JetBrainsMono Nerd Font)."
fi

# 2. Install Packages
PACKAGES=(
  "eza"
  "bat"
  "fzf"
  "zoxide"
)

CASKS=(
  "iterm2"
  "font-jetbrains-mono-nerd-font"
)

log "Updating Homebrew..."
execute 'brew update'

log "Installing command-line tools..."
for pkg in "${PACKAGES[@]}"; do
  if brew list -1 | grep -q "^${pkg}\$"; then
    log "${pkg} is already installed."
  else
    log "Installing ${pkg}..."
    execute "brew install ${pkg}"
  fi
done

log "Installing Cask applications..."
for cask in "${CASKS[@]}"; do
  if brew list --cask -1 | grep -q "^${cask}\$"; then
    log "${cask} is already installed."
  else
    log "Installing ${cask}..."
    execute "brew install --cask ${cask}"
  fi
done

# 3. Install Oh My Zsh
OMZ_DIR="${DEST_DIR}/.oh-my-zsh"
if [ ! -d "$OMZ_DIR" ]; then
  log "Installing Oh My Zsh into ${OMZ_DIR}..."
  if [ "$DRY_RUN" -eq 1 ]; then
    execute "git clone https://github.com/ohmyzsh/ohmyzsh.git ${OMZ_DIR}"
  else
    ZSH="$OMZ_DIR" KEEP_ZSHRC=yes RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
else
  log "Oh My Zsh is already installed at ${OMZ_DIR}."
fi

# 4. Symlink .zshrc
SRC_ZSHRC="${REPO_DIR}/.zshrc"
DEST_ZSHRC="${DEST_DIR}/.zshrc"

log "Configuring .zshrc..."
if [ -f "$DEST_ZSHRC" ] || [ -L "$DEST_ZSHRC" ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    log "Would backup existing ${DEST_ZSHRC} to ${DEST_ZSHRC}.backup"
    execute "ln -sf ${SRC_ZSHRC} ${DEST_ZSHRC}"
  else
    log "Backing up existing ${DEST_ZSHRC} to ${DEST_ZSHRC}.backup"
    mv "$DEST_ZSHRC" "${DEST_ZSHRC}.backup"
    log "Creating symlink for .zshrc in ${DEST_DIR}"
    ln -s "$SRC_ZSHRC" "$DEST_ZSHRC"
  fi
else
  log "Creating symlink for .zshrc in ${DEST_DIR}"
  execute "ln -s ${SRC_ZSHRC} ${DEST_ZSHRC}"
fi

log "Setup complete!"

# Optional: Install Claude Code CLI
if command -v npm &> /dev/null; then
  log "npm found. Checking for Claude Code CLI..."
  if ! command -v claude &> /dev/null; then
    log "Installing Claude Code CLI..."
    execute "npm install -g @anthropic-ai/claude-code"
  else
    log "Claude Code CLI is already installed."
  fi
else
  warn "npm not found. Skipping Claude Code CLI installation."
fi

log "Please restart your terminal or run: source ${DEST_ZSHRC}"
