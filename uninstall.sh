#!/bin/bash

# Configuration
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

execute() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo -e "\033[1;36m[DRY-RUN]\033[0m Would execute: $1"
  else
    eval "$1"
  fi
}

log "Starting macOS Terminal Uninstall..."
if [ "$DRY_RUN" -eq 1 ]; then
  log "Running in DRY-RUN mode. No changes will be made."
fi

# 1. Remove .zshrc symlink and restore backup
DEST_ZSHRC="${DEST_DIR}/.zshrc"
BACKUP_ZSHRC="${DEST_ZSHRC}.backup"

log "Restoring .zshrc..."
if [ -L "$DEST_ZSHRC" ]; then
  log "Removing symlink ${DEST_ZSHRC}"
  execute "rm ${DEST_ZSHRC}"
  if [ -f "$BACKUP_ZSHRC" ]; then
    log "Restoring backup ${BACKUP_ZSHRC} to ${DEST_ZSHRC}"
    execute "mv ${BACKUP_ZSHRC} ${DEST_ZSHRC}"
  fi
else
  log "No symlink found at ${DEST_ZSHRC}."
fi

# 2. Uninstall Oh My Zsh
OMZ_DIR="${DEST_DIR}/.oh-my-zsh"
if [ -d "$OMZ_DIR" ]; then
  log "Uninstalling Oh My Zsh from ${OMZ_DIR}..."
  execute "rm -rf ${OMZ_DIR}"
else
  log "Oh My Zsh directory not found at ${OMZ_DIR}."
fi

# 3. Optional: Uninstall Packages
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

if [ "$DRY_RUN" -0 ]; then
  read -p "Do you want to uninstall the Homebrew packages (eza, bat, fzf, zoxide, iterm2)? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Uninstalling command-line tools..."
    for pkg in "${PACKAGES[@]}"; do
      execute "brew uninstall ${pkg}"
    done
    log "Uninstalling Cask applications..."
    for cask in "${CASKS[@]}"; do
      execute "brew uninstall --cask ${cask}"
    done
  else
    log "Skipping Homebrew package uninstallation."
  fi

  # Uninstall Claude Code if npm is present
  if command -v npm &> /dev/null && command -v claude &> /dev/null; then
    read -p "Do you want to uninstall Claude Code CLI? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      log "Uninstalling Claude Code CLI..."
      execute "npm uninstall -g @anthropic-ai/claude-code"
    fi
  fi
else
  log "[DRY-RUN] Would prompt to uninstall Homebrew packages and Claude Code."
  for pkg in "${PACKAGES[@]}"; do
    execute "brew uninstall ${pkg}"
  done
  for cask in "${CASKS[@]}"; do
    execute "brew uninstall --cask ${cask}"
  done
  execute "npm uninstall -g @anthropic-ai/claude-code"
fi

log "Uninstall complete!"
