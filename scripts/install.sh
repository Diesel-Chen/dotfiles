#!/bin/bash

set -e

# 自动检测 dotfiles 目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "  Dotfiles Installation Script"
echo "=========================================="
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ------------------------- Homebrew -------------------------
# 检测 Homebrew 前缀路径
if [[ $(uname -m) == 'arm64' ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
else
    HOMEBREW_PREFIX="/usr/local"
fi

if ! command -v brew &> /dev/null; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
else
    print_info "Homebrew already installed"
fi

# ------------------------- Oh My Zsh -------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    print_info "Oh My Zsh already installed"
fi

# ------------------------- 切换默认 Shell 到 zsh -------------------------
if [[ "$SHELL" != *"zsh" ]]; then
    print_info "Switching default shell to zsh..."
    chsh -s "$(which zsh)" 2>/dev/null || {
        print_warn "无法自动切换 shell，请手动运行: chsh -s \$(which zsh)"
    }
else
    print_info "Default shell is already zsh"
fi

# ------------------------- Powerlevel10k -------------------------
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    print_info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    print_info "Powerlevel10k already installed"
fi

# ------------------------- Zsh 第三方插件 -------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    print_info "zsh-autosuggestions already installed"
fi

# zsh-history-substring-search
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
    print_info "Installing zsh-history-substring-search..."
    git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
else
    print_info "zsh-history-substring-search already installed"
fi

# fast-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
    print_info "Installing fast-syntax-highlighting..."
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
else
    print_info "fast-syntax-highlighting already installed"
fi

# ------------------------- Brew Bundle -------------------------
print_info "Running brew bundle..."
cd "$DOTFILES_DIR"
brew bundle

# ------------------------- GNU Stow -------------------------
print_info "Stowing dotfiles..."
cd "$DOTFILES_DIR"

# Remove existing config files that would conflict
[ -f "$HOME/.zshrc" ] && rm -f "$HOME/.zshrc"
[ -f "$HOME/.zprofile" ] && rm -f "$HOME/.zprofile"
[ -f "$HOME/.gitconfig" ] && rm -f "$HOME/.gitconfig"
[ -f "$HOME/.vimrc" ] && rm -f "$HOME/.vimrc"
[ -f "$HOME/.ssh/config" ] && rm -f "$HOME/.ssh/config"
[ -L "$HOME/.iterm2" ] && rm -f "$HOME/.iterm2"

stow --target="$HOME" zsh
stow --target="$HOME" git
stow --target="$HOME" vim
stow --target="$HOME" ssh
stow --target="$HOME" iterm2

# Ensure .ssh directory and config have correct permissions
[ -d "$HOME/.ssh" ] && chmod 700 "$HOME/.ssh"
[ -f "$HOME/.ssh/config" ] && chmod 600 "$HOME/.ssh/config"

# ------------------------- iTerm2 Configuration -------------------------
print_info "Configuring iTerm2..."
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 PrefsCustomFolder "$HOME/.iterm2"
print_info "iTerm2 configured to load from ~/.iterm2"

# ------------------------- fzf Key Bindings -------------------------
FZF_INSTALL="$HOMEBREW_PREFIX/opt/fzf/install"
if [ -f "$FZF_INSTALL" ]; then
    print_info "Setting up fzf key bindings..."
    "$FZF_INSTALL" --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# ------------------------- Permissions -------------------------
print_info "Setting script permissions..."
chmod +x "$DOTFILES_DIR/scripts/install.sh"

echo ""
echo "=========================================="
echo -e "${GREEN}Installation complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Configure Powerlevel10k (if needed): p10k configure"
echo ""
