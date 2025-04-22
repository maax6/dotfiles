#!/bin/bash

set -e

echo "[+] Installation de l’environnement Zsh personnalisé pour macOS..."

# Vérifier Homebrew
if ! command -v brew &>/dev/null; then
    echo "❌ Homebrew n'est pas installé. Installe-le d'abord depuis https://brew.sh/"
    exit 1
fi

# Installer les outils nécessaires
echo "[+] Installation des paquets Homebrew..."
brew install zsh git lsd bat

# Définir zsh comme shell par défaut
chsh -s /bin/zsh

# ─────────────────────────────────────────────────────
# 🧠 Oh My Zsh
# ─────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[+] Installation de Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "[+] Installation des plugins Zsh..."
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || true
git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions" || true

echo "[+] Installation du thème powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k" || true

# ─────────────────────────────────────────────────────
# 📝 .zshrc personnalisé
# ─────────────────────────────────────────────────────
echo "[+] Génération du .zshrc..."

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
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  sudo
  z
)

# ───────────────────────────────────────────────
# 🚀 Oh My Zsh Core
# ───────────────────────────────────────────────
source $ZSH/oh-my-zsh.sh

# ───────────────────────────────────────────────
# 🔌 Plugins Manuels
# ───────────────────────────────────────────────
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
[[ -f $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ───────────────────────────────────────────────
# 🔖 Aliases Utiles avec lsd et bat
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
# 💎 Powerlevel10k Configuration
# ───────────────────────────────────────────────
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOF

echo "[✓] Setup terminé ! Ouvre un nouveau terminal ou lance 'zsh' pour appliquer la config."
