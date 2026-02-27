# Dotfiles

个人开发环境配置文件，使用 GNU Stow 管理。

## 快速开始

```bash
# 克隆仓库
git clone git@github.com:Diesel-Chen/dotfiles.git ~/Personal/dotfiles

# 创建目录结构
./scripts/setup-dirs.sh

# 安装配置
./scripts/install.sh
```

## 目录结构

```
dotfiles/
├── zsh/               # Shell 配置
│   ├── .zshrc
│   └── .zprofile
├── vim/               # Vim 配置
│   └── .vimrc
├── git/               # Git 配置
│   └── .gitconfig
├── ssh/               # SSH 配置
│   └── .ssh/config
├── iterm2/            # iTerm2 配置
│   └── com.googlecode.iterm2.plist
├── scripts/           # 脚本
│   ├── install.sh     # 安装脚本
│   └── setup-dirs.sh  # 创建目录结构
└── Brewfile           # Homebrew 依赖
```

## 主要工具

| 工具 | 用途 |
|------|------|
| [Oh My Zsh](https://ohmyz.sh/) | Shell 框架 |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | Zsh 主题 |
| [GNU Stow](https://www.gnu.org/software/stow/) | 配置文件管理 |
| [Homebrew](https://brew.sh/) | 包管理器 |
| [fzf](https://github.com/junegunn/fzf) | 模糊搜索 |
| [fnm](https://github.com/Schniz/fnm) | Node 版本管理 |

## Zsh 插件

- `git` - Git 别名
- `z` - 目录跳转
- `brew` - Homebrew 补全
- `fzf` - 模糊搜索
- `zsh-autosuggestions` - 命令建议
- `zsh-history-substring-search` - 历史搜索
- `fast-syntax-highlighting` - 语法高亮

## 在新机器上设置

```bash
# 1. 克隆仓库
git clone git@github.com:Diesel-Chen/dotfiles.git ~/Personal/dotfiles
cd ~/Personal/dotfiles

# 2. 创建目录结构
./scripts/setup-dirs.sh

# 3. 运行安装脚本
./scripts/install.sh

# 4. 重启终端或执行
source ~/.zshrc

# 5. 配置 Powerlevel10k (可选)
p10k configure
```

## 更新配置

修改 dotfiles 中的文件后，配置会自动生效（因为是符号链接）。

```bash
# 提交更改
git add .
git commit -m "Update config"
git push
```

## 目录结构说明

```
~/Workspace/           # 工作空间（高频访问）
~/Projects/            # 项目代码库（长期维护）
~/Personal/            # 个人资料
~/Learning/            # 学习资源
~/Archive/             # 归档（按年份）
~/Temp/                # 临时文件（定期清理）
```

运行 `./scripts/setup-dirs.sh` 创建完整目录结构。
