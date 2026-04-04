# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS terminal configuration dotfiles repo. It automates installing and symlinking a `.zshrc` that configures Oh My Zsh with modern CLI replacements (eza, bat, fzf, zoxide), iTerm2, JetBrainsMono Nerd Font, and optionally Claude Code CLI.

## Key Commands

```bash
# Simulate install without making changes
./install.sh --dry-run

# Install (symlinks .zshrc to $HOME, installs Homebrew packages + Oh My Zsh)
./install.sh

# Test into an isolated directory
mkdir -p /tmp/teste-dotfiles && DEST_DIR=/tmp/teste-dotfiles ./install.sh

# Uninstall (restores .zshrc.backup, optionally removes packages)
./uninstall.sh

# Preview uninstall
./uninstall.sh --dry-run
```

## Architecture

The repo has the following files:

1. **`install.sh`** — installs Homebrew if missing, installs CLI packages (`eza`, `bat`, `fzf`, `zoxide`) and casks (`iterm2`, `font-jetbrains-mono-nerd-font`) via Homebrew, clones Oh My Zsh, symlinks `.zshrc` → `$HOME/.zshrc` (backing up any existing one as `.zshrc.backup`), and optionally installs Claude Code CLI via npm. Warns if running on Apple Terminal (Nerd Font symbols may not render). Respects `DEST_DIR` env var and `--dry-run` flag.

2. **`.zshrc`** — the managed config. Sets Oh My Zsh theme (`robbyrussell`), loads plugins (`git`, `zoxide`, `fzf`), and conditionally aliases `ls`/`ll`/`la`/`lt` to `eza` and `cat` to `bat`. Uses `${DEST_DIR:-$HOME}` so it works in test installs. **Note:** this file is referenced by `install.sh` but must exist in the repo root for the symlink step to work.

3. **`uninstall.sh`** — removes the symlink, restores the backup, removes `~/.oh-my-zsh`, optionally uninstalls Homebrew packages and Claude Code CLI (interactive prompts, skipped in dry-run).

4. **`README.md`** — user-facing documentation in Portuguese covering tools, usage, and repo structure.
