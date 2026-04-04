# Dotfiles - Configuração de Terminal (macOS & Debian/Ubuntu)

Este repositório contém scripts para automatizar a configuração do terminal no macOS e em distribuições baseadas em Debian (Ubuntu, etc.), utilizando ferramentas modernas para produtividade.

## Ferramentas Incluídas

- **Shell Framework:** [Oh My Zsh](https://ohmyz.sh/)
- **Utilitários CLI:**
  - `eza`: Substituto moderno do `ls` (com ícones e cores).
  - `bat` / `batcat`: Substituto do `cat` com syntax highlighting.
  - `fzf`: Buscador de arquivos fuzzy no terminal.
  - `zoxide`: Substituto inteligente do `cd` que aprende seus caminhos.
- **Terminal (apenas macOS):** [iTerm2](https://iterm2.com/)
- **Fontes:** JetBrainsMono Nerd Font (opcional, mas recomendada).

## Como Usar

### 1. Testar antes de instalar (Seguro)

Você pode simular a instalação para ver o que o script faria sem alterar nenhum arquivo:

```bash
./install.sh --dry-run
```

Ou testar a criação dos arquivos em um diretório temporário isolado:

```bash
mkdir -p /tmp/teste-dotfiles
DEST_DIR=/tmp/teste-dotfiles ./install.sh
```

### 2. Instalação Real

Para aplicar as configurações no seu usuário atual:

```bash
./install.sh
```

*Nota: No Debian/Ubuntu, o script solicitará privilégios de `sudo` para instalar os pacotes via `apt`.*
*O script fará backup do seu `.zshrc` atual como `.zshrc.backup` antes de criar o link simbólico.*

### 3. Desinstalação

Para remover as configurações e tentar restaurar o backup do seu `.zshrc`:

```bash
./uninstall.sh
```

## Estrutura do Repositório

- `install.sh`: Script de instalação com detecção automática de OS (macOS/Debian).
- `uninstall.sh`: Script para reverter as alterações.
- `.zshrc`: Arquivo de configuração do Zsh com aliases e plugins pré-configurados.
- `README.md`: Esta documentação.
