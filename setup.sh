#!/bin/bash
set -euo pipefail

echo "==> Installing Xcode Command Line Tools"
xcode-select --install 2>/dev/null || true

echo "==> Installing Homebrew"
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> Installing packages from Brewfile"
brew bundle --file="$HOME/dotfiles/Brewfile"

echo "==> Stowing dotfiles"
cd "$HOME/dotfiles"
stow zsh ripgrep oh-my-posh ghostty

echo "==> Done. Restart your terminal."
