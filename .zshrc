# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Configuração do Zsh (Gerenciado por dotfiles)

# DICA: Para que os ícones funcionem corretamente (sem interrogações), 
# certifique-se de usar uma "Nerd Font" no seu terminal (ex: JetBrainsMono Nerd Font).
# No iTerm2: Settings > Profiles > Text > Font > JetBrainsMono Nerd Font.

# Adicionar local bin e Homebrew ao PATH
export PATH="$HOME/.local/bin:$PATH"

if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Inicializar gerenciador de versões asdf
if [[ -f $HOME/.asdf/asdf.sh ]]; then
  source $HOME/.asdf/asdf.sh
elif [[ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]]; then
  source /opt/homebrew/opt/asdf/libexec/asdf.sh
fi

# Caminho para a instalação do Oh My Zsh.
export ZSH="${DEST_DIR:-$HOME}/.oh-my-zsh"

# Configuração do Tema Powerlevel10k
# Na primeira execução, ele iniciará o assistente de configuração automática.
ZSH_THEME="powerlevel10k/powerlevel10k"

# Esconder 'user@hostname' por padrão se for o usuário principal
DEFAULT_USER="jaimersoncorrea"

# Plugins
# git: status do git no prompt
# zoxide: cd inteligente
# fzf: busca fuzzy
# zsh-autosuggestions: sugestões de comandos baseadas no histórico
# zsh-syntax-highlighting: cores enquanto você digita os comandos
plugins=(
  git
  zoxide
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Carregar Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Configurações de Usuário

# Aliases
# eza aliases (substituto moderno do ls)
if command -v eza &> /dev/null; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -la --icons --group-directories-first"
  alias la="eza -a --icons --group-directories-first"
  alias lt="eza --tree --icons --group-directories-first"
fi

# bat aliases (substituto moderno do cat)
if command -v bat &> /dev/null; then
  alias cat="bat"
elif command -v batcat &> /dev/null; then
  alias cat="batcat"
  alias bat="batcat"
fi

# Inicializar zoxide
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Para personalizar o Powerlevel10k manualmente, use o comando: p10k configure
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
