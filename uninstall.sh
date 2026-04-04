#!/bin/bash

# Configuração
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

execute() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo -e "\033[1;36m[SIMULAÇÃO]\033[0m Executaria: $1"
  else
    eval "$1"
  fi
}

log "Iniciando desinstalação para $(uname -s)..."
if [ "$DRY_RUN" -eq 1 ]; then
  log "Executando em modo de SIMULAÇÃO. Nenhuma alteração real será feita."
fi

# 1. Remover link simbólico do .zshrc e restaurar backup
DEST_ZSHRC="${DEST_DIR}/.zshrc"
BACKUP_ZSHRC="${DEST_ZSHRC}.backup"

log "Restaurando .zshrc..."
if [ -L "$DEST_ZSHRC" ]; then
  log "Removendo link simbólico ${DEST_ZSHRC}"
  execute "rm ${DEST_ZSHRC}"
  if [ -f "$BACKUP_ZSHRC" ]; then
    log "Restaurando backup ${BACKUP_ZSHRC} para ${DEST_ZSHRC}"
    execute "mv ${BACKUP_ZSHRC} ${DEST_ZSHRC}"
  fi
else
  log "Nenhum link simbólico encontrado em ${DEST_ZSHRC}."
fi

# 2. Desinstalar Oh My Zsh e resíduos do Powerlevel10k
OMZ_DIR="${DEST_DIR}/.oh-my-zsh"
if [ -d "$OMZ_DIR" ]; then
  log "Desinstalando Oh My Zsh de ${OMZ_DIR}..."
  execute "rm -rf ${OMZ_DIR}"
fi

# Remover arquivos residuais do Powerlevel10k
P10K_CONFIG="${DEST_DIR}/.p10k.zsh"
if [ -f "$P10K_CONFIG" ]; then
  log "Removendo arquivo de configuração do Powerlevel10k..."
  execute "rm ${P10K_CONFIG}"
fi

P10K_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-*"
if ls $P10K_CACHE 1> /dev/null 2>&1; then
  log "Limpando cache do instant prompt do Powerlevel10k..."
  execute "rm -f ${P10K_CACHE}"
fi

# 3. Desinstalar Pacotes
if [ "$IS_MACOS" -eq 1 ]; then
  PACKAGES=(eza bat fzf zoxide)
  CASKS=(iterm2 font-jetbrains-mono-nerd-font)
  
  if [ "$DRY_RUN" -eq 0 ]; then
    read -p "Deseja desinstalar os pacotes do Homebrew (eza, bat, fzf, zoxide, iterm2)? [s/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
      for pkg in "${PACKAGES[@]}"; do execute "brew uninstall ${pkg}"; done
      for cask in "${CASKS[@]}"; do execute "brew uninstall --cask ${cask}"; done
    fi
  else
    for pkg in "${PACKAGES[@]}"; do execute "brew uninstall ${pkg}"; done
    for cask in "${CASKS[@]}"; do execute "brew uninstall --cask ${cask}"; done
  fi
elif [ "$IS_DEBIAN" -eq 1 ]; then
  DEBIAN_PKGS=(eza bat batcat fzf zoxide)
  
  if [ "$DRY_RUN" -eq 0 ]; then
    read -p "Deseja desinstalar os pacotes do Debian (eza, bat/batcat, fzf, zoxide)? [s/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
      execute "sudo apt-get remove -y ${DEBIAN_PKGS[*]}"
      execute "sudo apt-get autoremove -y"
      # Limpar repositório eza
      log "Limpando repositório do eza..."
      execute "sudo rm -f /etc/apt/sources.list.d/gierens.list"
      execute "sudo rm -f /etc/apt/keyrings/gierens.gpg"
    fi
  else
    execute "sudo apt-get remove -y ${DEBIAN_PKGS[*]}"
  fi
  
  # Remover link simbólico do batcat se existir
  if [ -L "$HOME/.local/bin/bat" ]; then
    log "Removendo link simbólico do batcat..."
    execute "rm $HOME/.local/bin/bat"
  fi
fi

# 4. Opcional: Desinstalar Claude Code
if command -v npm &> /dev/null && command -v claude &> /dev/null; then
  if [ "$DRY_RUN" -eq 0 ]; then
    read -p "Deseja desinstalar o Claude Code CLI? [s/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
      execute "npm uninstall -g @anthropic-ai/claude-code"
    fi
  else
    execute "npm uninstall -g @anthropic-ai/claude-code"
  fi
fi

log "Desinstalação concluída!"
