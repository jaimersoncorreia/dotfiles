#!/bin/bash

# Configuração
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${DEST_DIR:-$HOME}"
DRY_RUN=0

# Detectar SO
OS_TYPE="$(uname -s)"
IS_MACOS=0
IS_DEBIAN=0

if [ "$OS_TYPE" == "Darwin" ]; then
  IS_MACOS=1
elif [ -f /etc/debian_version ]; then
  IS_DEBIAN=1
fi

# Processar argumentos
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
  esac
done

# Funções auxiliares
log() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
warn() { echo -e "\033[1;33m[AVISO]\033[0m $1"; }
error() { echo -e "\033[1;31m[ERRO]\033[0m $1"; }

execute() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo -e "\033[1;36m[SIMULAÇÃO]\033[0m Executaria: $1"
  else
    eval "$1"
  fi
}

log "Iniciando configuração do terminal para $(uname -s)..."
if [ "$DRY_RUN" -eq 1 ]; then
  log "Executando em modo de SIMULAÇÃO. Nenhuma alteração real será feita."
fi

# 1. Configuração do Gerenciador de Pacotes e Repositório Eza para Debian
if [ "$IS_MACOS" -eq 1 ]; then
  if ! command -v brew &> /dev/null; then
    log "Homebrew não encontrado. Instalando Homebrew..."
    execute '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    if [ -f /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
  fi
elif [ "$IS_DEBIAN" -eq 1 ]; then
  log "Atualizando repositórios do apt..."
  execute 'sudo apt-get update'
  
  # Tratamento especial para eza no Debian (frequentemente fora dos repos principais)
  if ! command -v eza &> /dev/null && [ "$DRY_RUN" -eq 0 ]; then
    log "Adicionando repositório do eza para Debian..."
    execute 'sudo apt-get install -y gpg'
    execute 'sudo mkdir -p /etc/apt/keyrings'
    execute 'wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg'
    execute 'echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list'
    execute 'sudo apt-get update'
  fi
fi

# 2. Instalar Pacotes
if [ "$IS_MACOS" -eq 1 ]; then
  PACKAGES=(eza bat fzf zoxide)
  CASKS=(iterm2 font-jetbrains-mono-nerd-font)
  for pkg in "${PACKAGES[@]}"; do
    brew list -1 | grep -q "^${pkg}\$" || execute "brew install ${pkg}"
  done
  for cask in "${CASKS[@]}"; do
    brew list --cask -1 | grep -q "^${cask}\$" || execute "brew install --cask ${cask}"
  done
elif [ "$IS_DEBIAN" -eq 1 ]; then
  DEBIAN_PKGS=(zsh fzf zoxide curl git wget)
  command -v bat &> /dev/null || command -v batcat &> /dev/null || DEBIAN_PKGS+=(bat)
  command -v eza &> /dev/null || DEBIAN_PKGS+=(eza)

  log "Instalando pacotes Debian: ${DEBIAN_PKGS[*]}"
  execute "sudo apt-get install -y ${DEBIAN_PKGS[*]}"
  
  if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    log "Criando link simbólico para batcat -> bat"
    execute "mkdir -p ~/.local/bin && ln -sf /usr/bin/batcat ~/.local/bin/bat"
  fi
fi

# 3. Instalar Oh My Zsh
OMZ_DIR="${DEST_DIR}/.oh-my-zsh"
if [ ! -d "$OMZ_DIR" ]; then
  log "Instalando Oh My Zsh..."
  if [ "$DRY_RUN" -eq 1 ]; then
    execute "git clone https://github.com/ohmyzsh/ohmyzsh.git ${OMZ_DIR}"
  else
    ZSH="$OMZ_DIR" KEEP_ZSHRC=yes RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
fi

# 4. Criar Link Simbólico do .zshrc
SRC_ZSHRC="${REPO_DIR}/.zshrc"
DEST_ZSHRC="${DEST_DIR}/.zshrc"
if [ -f "$DEST_ZSHRC" ] || [ -L "$DEST_ZSHRC" ]; then
  if [ "$DRY_RUN" -eq 0 ] && [ ! -L "$DEST_ZSHRC" ]; then
    log "Fazendo backup do .zshrc existente para .zshrc.backup"
    mv "$DEST_ZSHRC" "${DEST_ZSHRC}.backup"
  fi
fi
log "Configurando .zshrc..."
execute "ln -sf ${SRC_ZSHRC} ${DEST_ZSHRC}"

# 5. Definir Zsh como shell padrão no Linux
if [ "$IS_DEBIAN" -eq 1 ] && [[ "$SHELL" != *zsh ]]; then
  log "Alterando o shell padrão para zsh..."
  execute "sudo chsh -s $(which zsh) $(whoami)"
fi

# 6. Opcional: Claude Code CLI
if command -v npm &> /dev/null && ! command -v claude &> /dev/null; then
  log "Instalando Claude Code CLI..."
  execute "npm install -g @anthropic-ai/claude-code"
fi

log "Configuração concluída! Por favor, reinicie seu terminal ou execute: source ${DEST_ZSHRC}"
