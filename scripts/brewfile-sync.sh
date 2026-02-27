#!/bin/bash
# ~/Personal/dotfiles/scripts/brewfile-sync.sh
# 导出 Brewfile 并排除 macOS 原生应用

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BREWFILE="$DOTFILES_DIR/Brewfile"

# macOS 原生应用的 ADAM ID（需要排除）
EXCLUDE_IDS=(
    682658836   # GarageBand
    408981434   # iMovie
    409183694   # Keynote
    409203825   # Numbers
    409201541   # Pages
    409201541   # Pages
    409203825   # Numbers
    497746817   # Xcode (可选，很大)
)

echo "正在导出 Brewfile..."

# 导出到临时文件
brew bundle dump --force --file="$BREWFILE.tmp"

# 过滤排除的应用
echo "过滤 macOS 原生应用..."
for id in "${EXCLUDE_IDS[@]}"; do
    /usr/bin/sed -i '' "/id: $id/d" "$BREWFILE.tmp"
done

# 替换原文件
/bin/mv "$BREWFILE.tmp" "$BREWFILE"

echo "✅ Brewfile 已更新: $BREWFILE"
echo ""
echo "更改内容:"
git diff "$BREWFILE" || echo "无变更"
