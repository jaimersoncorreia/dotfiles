#!/bin/bash

# Configuração
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${DEST_DIR:-$HOME}"
DRY_RUN=0

# Detectar SO
OS_TYPE="$(uname -s)"
IS_MACOS=0
IS_DEBIAN=0
IS_WSL=0

if [ "$OS_TYPE" == "Darwin" ]; then
  IS_MACOS=1
elif [ -f /etc/debian_version ]; then
  IS_DEBIAN=1
fi

if grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=1
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

  # Instalar JetBrainsMono Nerd Font
  FONT_VERSION="v3.3.0"
  FONT_ZIP="/tmp/JetBrainsMono.zip"

  if [ "$IS_WSL" -eq 1 ]; then
    # No WSL, a fonte precisa ser instalada no Windows para o terminal usar
    WIN_USER="$(powershell.exe -NoProfile -Command 'echo $env:USERNAME' 2>/dev/null | tr -d '\r')"
    WIN_USER_FONTS="/mnt/c/Users/${WIN_USER}/AppData/Local/Microsoft/Windows/Fonts"
    WIN_SRC="C:\\Users\\${WIN_USER}\\AppData\\Local\\Microsoft\\Windows\\Fonts"
    # Máquinas corporativas podem ignorar fontes por usuário (AppData), então instala em C:\Windows\Fonts
    PS_SCRIPT="/mnt/c/Users/Public/install-jetbrains-nf.ps1"

    if [ -n "$WIN_USER" ] && [ -d "/mnt/c/Users/${WIN_USER}" ]; then
      if [ -n "$(ls /mnt/c/Windows/Fonts/JetBrainsMono*Nerd*.ttf 2>/dev/null)" ]; then
        log "JetBrainsMono Nerd Font já instalada no Windows."
      else
        if [ -z "$(ls "${WIN_USER_FONTS}"/JetBrainsMono*Nerd*.ttf 2>/dev/null)" ]; then
          log "Baixando JetBrainsMono Nerd Font..."
          execute "mkdir -p '${WIN_USER_FONTS}'"
          execute "wget -q --show-progress -O ${FONT_ZIP} https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/JetBrainsMono.zip"
          execute "unzip -o ${FONT_ZIP} -d /tmp/JetBrainsMono '*.ttf'"
          execute "cp /tmp/JetBrainsMono/*.ttf '${WIN_USER_FONTS}/'"
          execute "rm -rf /tmp/JetBrainsMono ${FONT_ZIP}"
        fi

        log "Instalando a fonte para todos os usuários (o Windows vai pedir credenciais de administrador)..."
        if [ "$DRY_RUN" -eq 1 ]; then
          echo -e "\033[1;36m[SIMULAÇÃO]\033[0m Executaria: instalação elevada das fontes em C:\\Windows\\Fonts"
        else
          cat > "$PS_SCRIPT" <<'EOF'
$src = '__SRC__'
$reg = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
Get-ChildItem "$src\JetBrainsMono*Nerd*.ttf" | ForEach-Object {
  Copy-Item $_.FullName "$env:windir\Fonts\$($_.Name)" -Force
  New-ItemProperty -Path $reg -Name "$($_.BaseName) (TrueType)" -Value $_.Name -PropertyType String -Force | Out-Null
}
EOF
          sed -i "s|__SRC__|${WIN_SRC//\\/\\\\}|" "$PS_SCRIPT"
          powershell.exe -NoProfile -Command "Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\\Users\\Public\\install-jetbrains-nf.ps1'" 2>/dev/null
          rm -f "$PS_SCRIPT"
        fi

        if [ "$DRY_RUN" -eq 1 ] || [ -n "$(ls /mnt/c/Windows/Fonts/JetBrainsMono*Nerd*.ttf 2>/dev/null)" ]; then
          log "Fonte instalada no Windows. Saia e entre de novo na conta do Windows se o terminal não a encontrar."
        else
          warn "Não foi possível instalar a fonte para todos os usuários (sem permissão de administrador?)."
          warn "  Os arquivos estão em ${WIN_SRC}."
          warn "  Selecione os .ttf > botão direito > 'Instalar para todos os usuários'."
        fi
        warn "Configure seu terminal para usar 'JetBrainsMono NF' (nome da fonte no Windows)."
        warn "  Windows Terminal: settings.json > \"font\": { \"face\": \"JetBrainsMono NF\" }"
        warn "  VSCode: settings.json > \"terminal.integrated.fontFamily\": \"'JetBrainsMono NF', monospace\""
      fi
    else
      warn "Não foi possível detectar usuário Windows. Instale a fonte manualmente:"
      warn "  Baixe: https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/JetBrainsMono.zip"
      warn "  Extraia e instale os .ttf clicando com botão direito > 'Instalar para todos os usuários'"
    fi
  else
    FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
    if [ ! -d "$FONT_DIR" ] || [ -z "$(ls -A "$FONT_DIR" 2>/dev/null)" ]; then
      log "Instalando JetBrainsMono Nerd Font..."
      execute "mkdir -p ${FONT_DIR}"
      execute "wget -q --show-progress -O ${FONT_ZIP} https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/JetBrainsMono.zip"
      execute "unzip -o ${FONT_ZIP} -d ${FONT_DIR} '*.ttf'"
      execute "rm -f ${FONT_ZIP}"
      execute "fc-cache -fv ${FONT_DIR}"
    else
      log "JetBrainsMono Nerd Font já instalada."
    fi
  fi
fi

# 3. Instalar Oh My Zsh e Plugins/Temas
OMZ_DIR="${DEST_DIR}/.oh-my-zsh"
ZSH_CUSTOM="${OMZ_DIR}/custom"

if [ ! -d "$OMZ_DIR" ]; then
  log "Instalando Oh My Zsh..."
  if [ "$DRY_RUN" -eq 1 ]; then
    execute "git clone https://github.com/ohmyzsh/ohmyzsh.git ${OMZ_DIR}"
  else
    ZSH="$OMZ_DIR" KEEP_ZSHRC=yes RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
fi

# Instalar Powerlevel10k
P10K_DIR="${ZSH_CUSTOM}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  log "Instalando tema Powerlevel10k..."
  execute "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${P10K_DIR}"
fi

# Instalar Plugins Customizados
PLUGINS=(
  "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
  "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
)

for plugin_info in "${PLUGINS[@]}"; do
  plugin_name="${plugin_info%%:*}"
  plugin_url="${plugin_info#*:}"
  plugin_dir="${ZSH_CUSTOM}/plugins/${plugin_name}"
  
  if [ ! -d "$plugin_dir" ]; then
    log "Instalando plugin ${plugin_name}..."
    execute "git clone ${plugin_url} ${plugin_dir}"
  fi
done

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
