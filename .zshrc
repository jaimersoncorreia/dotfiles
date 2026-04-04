# Add local bin and Homebrew to PATH
export PATH="$HOME/.local/bin:$PATH"

if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Initialize asdf version manager
if [[ -f $HOME/.asdf/asdf.sh ]]; then
  source $HOME/.asdf/asdf.sh
elif [[ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]]; then
  source /opt/homebrew/opt/asdf/libexec/asdf.sh
fi

# Path to your oh-my-zsh installation.
export ZSH="${DEST_DIR:-$HOME}/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set default user for agnoster theme to hide 'user@hostname' if it matches
DEFAULT_USER="jaimersoncorrea"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zoxide
  fzf
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration

# Aliases
# eza aliases (modern ls replacement)
if command -v eza &> /dev/null; then
  alias ls="eza --icons"
  alias ll="eza -la --icons"
  alias la="eza -a --icons"
  alias lt="eza --tree --icons"
fi

# bat aliases (modern cat replacement)
if command -v bat &> /dev/null; then
  alias cat="bat"
fi

# Initialize zoxide (smarter cd)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi
