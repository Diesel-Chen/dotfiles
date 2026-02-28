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
CYAN='\033[0;36m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "\n${CYAN}==>${NC} $1"; }

# ------------------------- 系统检测 -------------------------
# 检测 macOS 版本
MACOS_VERSION=$(sw_vers -productVersion | cut -d. -f1)
MACOS_MAJOR=$(sw_vers -productVersion | cut -d. -f2)
IS_LEGACY_MACOS=false

if [[ "$MACOS_VERSION" -lt 13 ]]; then
    IS_LEGACY_MACOS=true
    print_warn "检测到 macOS $MACOS_VERSION (Tier 3 支持)"
    print_warn "部分软件需要从源码编译，耗时较长，请耐心等待..."
fi

# 检测芯片架构
if [[ $(uname -m) == 'arm64' ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
    ARCH="Apple Silicon"
else
    HOMEBREW_PREFIX="/usr/local"
    ARCH="Intel"
fi

print_info "系统: macOS $MACOS_VERSION | 架构: $ARCH | Homebrew: $HOMEBREW_PREFIX"

# ------------------------- Homebrew -------------------------
if ! command -v brew &> /dev/null; then
    print_step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
else
    print_info "Homebrew already installed"
fi

# 设置并行编译加速
export HOMEBREW_MAKE_JOBS=$(sysctl -n hw.ncpu)
print_info "并行编译任务数: $HOMEBREW_MAKE_JOBS"

# ------------------------- Oh My Zsh -------------------------
print_step "Setting up Oh My Zsh..."
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
print_step "Installing Zsh theme and plugins..."
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
print_step "Installing Homebrew packages..."

cd "$DOTFILES_DIR"

if [[ "$IS_LEGACY_MACOS" == true ]]; then
    print_warn "旧版 macOS 将逐个安装，便于观察进度..."

    # 逐个安装 brew 包
    brew_packages=(fnm fzf git neofetch redis stow tree uv)
    for pkg in "${brew_packages[@]}"; do
        if brew list "$pkg" &>/dev/null; then
            print_info "$pkg already installed"
        else
            print_info "Installing $pkg (可能需要从源码编译，请耐心等待)..."
            brew install "$pkg" || print_warn "$pkg 安装失败，稍后可手动安装"
        fi
    done

    # 逐个安装 cask
    casks=(appcleaner google-chrome iterm2 visual-studio-code claude-code codex font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font)
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            print_info "$cask already installed"
        else
            print_info "Installing $cask..."
            brew install --cask "$cask" || print_warn "$cask 安装失败，稍后可手动安装"
        fi
    done

    # mas 安装（如果 mas 可用）
    if command -v mas &>/dev/null; then
        mas_apps=("BaiduNetdisk:547166701" "Bitwarden:1352778147" "Bob:1630034110" "CleanMyMac:1339170533" "DingTalk:1435447041" "WeChat:836500024")
        for app in "${mas_apps[@]}"; do
            name="${app%%:*}"
            id="${app##*:}"
            if mas list | grep -q "$id"; then
                print_info "$name already installed"
            else
                print_info "Installing $name from App Store..."
                mas install "$id" || print_warn "$name 安装失败"
            fi
        done
    else
        print_warn "mas 未安装，跳过 App Store 应用。请手动从 App Store 下载。"
    fi
else
    # 新版 macOS 直接用 brew bundle
    brew bundle
fi

# ------------------------- GNU Stow -------------------------
print_step "Stowing dotfiles..."
cd "$DOTFILES_DIR"

# Remove existing config files that would conflict
[ -f "$HOME/.zshrc" ] && rm -f "$HOME/.zshrc"
[ -f "$HOME/.zprofile" ] && rm -f "$HOME/.zprofile"
[ -f "$HOME/.gitconfig" ] && rm -f "$HOME/.gitconfig"
[ -f "$HOME/.vimrc" ] && rm -f "$HOME/.vimrc"
[ -f "$HOME/.ssh/config" ] && rm -f "$HOME/.ssh/config"
[ -L "$HOME/.iterm2" ] && rm -f "$HOME/.iterm2"
[ -f "$HOME/Library/Application Support/PixPin/Config/PixPinConfig.json" ] && rm -f "$HOME/Library/Application Support/PixPin/Config/PixPinConfig.json"
[ -d "$HOME/Library/Containers/com.hezongyidev.Bob/Data/Documents/InstalledPlugin" ] && rm -rf "$HOME/Library/Containers/com.hezongyidev.Bob/Data/Documents/InstalledPlugin"

stow --target="$HOME" zsh
stow --target="$HOME" git
stow --target="$HOME" vim
stow --target="$HOME" ssh
stow --target="$HOME" iterm2
stow --target="$HOME" pixpin
stow --target="$HOME" bob

# Ensure .ssh directory and config have correct permissions
[ -d "$HOME/.ssh" ] && chmod 700 "$HOME/.ssh"
[ -f "$HOME/.ssh/config" ] && chmod 600 "$HOME/.ssh/config"

# ------------------------- iTerm2 Configuration -------------------------
print_step "Configuring iTerm2..."
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 PrefsCustomFolder "$HOME/.iterm2"
print_info "iTerm2 configured to load from ~/.iterm2"

# ------------------------- fzf Key Bindings -------------------------
if [ -f "$HOMEBREW_PREFIX/opt/fzf/install" ]; then
    print_info "Setting up fzf key bindings..."
    "$HOMEBREW_PREFIX/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# ------------------------- Permissions -------------------------
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
