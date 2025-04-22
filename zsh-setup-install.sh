#!/bin/bash

set -e

echo "🔍 Détection du système..."

OS="$(uname -s)"
ARCH="$(uname -m)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ───────────────────────────────────────────────
# 🔧 FONCTIONS
# ───────────────────────────────────────────────

install_mac_deps() {
  echo "[+] 📦 Installation avec Homebrew..."
  if ! command -v brew &>/dev/null; then
    echo "❌ Homebrew non trouvé. Installe-le d'abord depuis https://brew.sh"
    exit 1
  fi

  brew install zsh git lsd bat
}

install_ubuntu_deps() {
  echo "[+] 📦 Installation via APT..."
  sudo apt update
  sudo apt install -y zsh git curl bat fonts-powerline

  echo "[+] 📦 Installation de lsd..."
  if [[ "$ARCH" == "x86_64" ]]; then
    LSD_DEB="lsd_1.1.2_amd64.deb"
  elif [[ "$ARCH" == "aarch64" ]]; then
    LSD_DEB="lsd_1.1.2_arm64.deb"
  else
    echo "❌ Architecture non supportée pour lsd : $ARCH"
    exit 1
  fi

  curl -LO "https://github.com/lsd-rs/lsd/releases/download/v1.1.2/$LSD_DEB"
  sudo dpkg -i "$LSD_DEB" || sudo apt -f install -y
  rm "$LSD_DEB"
}

setup_ohmyzsh() {
  echo "[+] 🧠 Installation de Oh My Zsh..."
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
}

install_plugins_and_theme() {
  echo "[+] 🔌 Plugins et thèmes..."

  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
  git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions" 2>/dev/null || true
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k" 2>/dev/null || true
}

generate_zshrc() {
  echo "[+] 📝 Génération de .zshrc..."

  cat > ~/.zshrc << 'EOF'
# ───────────────────────────────────────────────
# ⚡ Instant Prompt Powerlevel10k
# ───────────────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ───────────────────────────────────────────────
# 🧠 Oh My Zsh + Theme
# ───────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions sudo z)

source $ZSH/oh-my-zsh.sh

# ───────────────────────────────────────────────
# 🔌 Plugins Manuels
# ───────────────────────────────────────────────
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
[[ -f $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ───────────────────────────────────────────────
# 🐱 Compatibilité bat/batcat
# ───────────────────────────────────────────────
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
  alias bat='batcat'
fi

# ───────────────────────────────────────────────
# 🔖 Aliases avec lsd + bat
# ───────────────────────────────────────────────
alias ls='lsd'
alias ll='lsd -alF'
alias la='lsd -A'
alias l='lsd -l'
alias lt='lsd --tree'
alias tree='lsd --tree'

alias cat='bat'
alias b='bat'
alias batn='bat --plain'
alias batp='bat --paging=always'
alias batl='bat --style=plain'

alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias grep='grep --color=auto'

# ───────────────────────────────────────────────
# 💎 Powerlevel10k
# ───────────────────────────────────────────────
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOF
}

# ───────────────────────────────────────────────
# 🧠 EXÉCUTION
# ───────────────────────────────────────────────

if [[ "$OS" == "Darwin" ]]; then
  install_mac_deps
elif [[ "$OS" == "Linux" && -f /etc/os-release && $(grep -i ID /etc/os-release) == *ubuntu* ]]; then
  install_ubuntu_deps
else
  echo "❌ OS non supporté ($OS)"
  exit 1
fi

setup_ohmyzsh
install_plugins_and_theme
generate_zshrc

# Définir Zsh comme shell par défaut
chsh -s $(which zsh)

echo "✅ Installation terminée. Lance 'zsh' ou redémarre ton terminal pour profiter de ta config."
