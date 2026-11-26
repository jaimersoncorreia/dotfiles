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
- **Fontes:** JetBrainsMono Nerd Font (obrigatória para ícones corretos).

## Como Corrigir Ícones (Pontos de Interrogação)

Se você vir pontos de interrogação `?` ou quadrados em vez de ícones no seu terminal, isso significa que a fonte correta não está selecionada nas configurações do seu aplicativo de terminal.

### No iTerm2 (macOS):
1. Abra o **iTerm2**.
2. Vá em **Settings** (ou `Cmd + ,`).
3. Clique na aba **Profiles**.
4. Selecione o seu perfil à esquerda (geralmente `Default`).
5. Clique na sub-aba **Text**.
6. Em **Font**, clique no botão para selecionar a fonte e escolha **JetBrainsMono Nerd Font**.
7. Certifique-se de que a opção **Use built-in Powerline glyphs** também esteja marcada.

### No Windows Terminal (WSL):
No Windows, a fonte aparece com o nome curto **JetBrainsMono NF**. Usar `JetBrainsMono Nerd Font` gera o erro "Não é possível localizar as seguintes fontes".
1. Abra as configurações (`Ctrl + ,`) > **Abrir arquivo JSON**.
2. Em `profiles.defaults`, defina:
   ```json
   "font": { "face": "JetBrainsMono NF" }
   ```

Se o erro continuar mesmo com o nome certo, a fonte provavelmente foi instalada só para o usuário (em `AppData\Local\Microsoft\Windows\Fonts`). Máquinas corporativas costumam ignorar essa pasta. Instale para todos os usuários: selecione os `.ttf` > botão direito > **Instalar para todos os usuários** (exige administrador). O `install.sh` já faz isso e pede as credenciais de administrador pelo UAC.

### No Terminal do VS Code:
1. Abra as **Settings** (`Cmd + ,` / `Ctrl + ,`).
2. Pesquise por `terminal.integrated.fontFamily`.
3. Defina o valor como `'JetBrainsMono NF', 'JetBrainsMono Nerd Font', monospace` (o primeiro nome é o do Windows; o segundo, o do macOS/Linux).

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
