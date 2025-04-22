#!/bin/bash
set -e

echo "🔍 Détection de l’environnement..."

OS="$(uname -s)"
ARCH="$(uname -m)"
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$OS" in
  Darwin)
    echo "🖥️ macOS détecté ($ARCH)"
    SCRIPT="$BASE_DIR/zsh-macos.sh"
    ;;
  Linux)
    if grep -qi 'ubuntu' /etc/os-release; then
      echo "🐧 Ubuntu détecté ($ARCH)"
      SCRIPT="$BASE_DIR/zsh-ubuntu.sh"
    else
      echo "❌ Ce script ne gère que Ubuntu. OS Linux détecté non supporté."
      exit 1
    fi
    ;;
  *)
    echo "❌ OS non supporté : $OS"
    exit 1
    ;;
esac

if [ ! -f "$SCRIPT" ]; then
  echo "❌ Script introuvable : $SCRIPT"
  exit 1
fi

echo "🚀 Lancement de $SCRIPT..."
chmod +x "$SCRIPT"
"$SCRIPT"
