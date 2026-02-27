#!/usr/bin/env zsh
# ~/Personal/dotfiles/scripts/setup-dirs.sh
# 创建你的标准目录结构，幂等（重复运行无副作用）

set -euo pipefail

# ======================
# 主目录列表
# ======================
declare -A DIRS

DIRS=(
  # ====================
  # Workspace - 工作空间（高频访问）
  # ====================
  ["Workspace/active"]="当前正在进行的项目"
  ["Workspace/experiments"]="快速验证想法、PoC 原型"
  ["Workspace/temp-clones"]="临时 clone 的热门 repo，用完可删"

  # ====================
  # Projects - 项目代码库（长期维护）
  # ====================
  ["Projects/Kuip"]="Kuip 项目代码"
  ["Projects/github"]="GitHub 开源项目"
  ["Projects/private"]="私有项目/客户项目"
  ["Projects/NNCZ"]="NNCZ 项目代码"

  # ====================
  # Personal - 个人资料
  # ====================
  ["Personal/dotfiles"]="配置文件仓库"
  ["Personal/documents"]="文档、证书、合同"
  ["Personal/family-photos"]="家庭照片"
  ["Personal/finance"]="财务记录、账单"
  ["Personal/health"]="健康记录"
  ["Personal/knowledge"]="知识库、笔记"
  ["Personal/security"]="加密敏感资料"

  # ====================
  # Learning - 学习资源
  # ====================
  ["Learning/challenges"]="编程挑战、LeetCode 等"
  ["Learning/clones/github.com"]="克隆学习的开源项目"
  ["Learning/courses"]="课程资料、教程"
  ["Learning/playgrounds"]="语言/框架实验场"

  # ====================
  # Archive - 归档（按年份）
  # ====================
  ["Archive/2020"]="2020 年归档"
  ["Archive/2021"]="2021 年归档"
  ["Archive/2022"]="2022 年归档"
  ["Archive/2023"]="2023 年归档"
  ["Archive/2024"]="2024 年归档"
  ["Archive/2025"]="2025 年归档"
  ["Archive/2026"]="2026 年归档"

  # ====================
  # Temp - 临时文件（定期清理）
  # ====================
  ["Temp/downloads"]="下载文件临时存放"
  ["Temp/extracts"]="解压文件临时存放"
  ["Temp/installers"]="安装包临时存放"
  ["Temp/screenshots"]="截图临时存放"
  ["Temp/trash-auto"]="待删除文件，定期清理"
)

echo "开始创建/检查目录结构..."

for path in "${(@k)DIRS}"; do
  full_path="$HOME/$path"
  if [[ -d "$full_path" ]]; then
    print -P "%F{green}已存在： ~/$path%f"
  else
    /bin/mkdir -p "$full_path"
    print -P "%F{yellow}创建： ~/$path%f"
  fi
done

# 每年自动创建当年的 Archive 目录
current_year=$(/bin/date +%Y)
archive_year="$HOME/Archive/$current_year"
if [[ ! -d "$archive_year" ]]; then
  /bin/mkdir -p "$archive_year"
  print -P "%F{cyan}创建当年归档目录： ~/Archive/$current_year%f"
fi

echo ""
echo "目录结构初始化/检查完成！"
echo "下次需要新增目录时："
echo "  1. 编辑这个脚本，加入新路径"
echo "  2. git commit & push"
echo "  3. 在其他机器上 git pull 后再跑一次此脚本"
