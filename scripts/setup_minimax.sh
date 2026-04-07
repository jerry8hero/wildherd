#!/bin/bash
# MiniMax API 配置脚本
# 用法: bash scripts/setup_minimax.sh

echo "============================================"
echo "  MiniMax API 配置"
echo "============================================"
echo ""

# 检查是否提供了参数
if [ -z "$1" ]; then
    echo "请提供 API Key:"
    echo "  bash scripts/setup_minimax.sh <your_api_key>"
    echo ""
    echo "或者直接运行以下命令设置环境变量:"
    echo "  export MINIMAX_API_KEY='your_api_key'"
    echo "  export MINIMAX_GROUP_ID='your_group_id'"
    exit 1
fi

API_KEY="$1"
GROUP_ID="$2"

# 创建或更新 .env 文件
ENV_FILE="$(dirname "$0")/../.env"

echo "API Key: ${API_KEY:0:10}...${API_KEY: -4}"
echo "Group ID: $GROUP_ID"
echo ""

# 写入 .env 文件
cat > "$ENV_FILE" << EOF
# MiniMax API 配置
MINIMAX_API_KEY=$API_KEY
MINIMAX_GROUP_ID=$GROUP_ID
EOF

echo "✅ 配置已保存到: $ENV_FILE"
echo ""

# 添加到 shell 配置
SHELL_RC="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
fi

# 检查是否已经配置过
if grep -q "MINIMAX_API_KEY" "$SHELL_RC" 2>/dev/null; then
    echo "⚠️ 检测到 ~/.bashrc 中已有 MINIMAX_API_KEY 配置"
    echo "   如需更新，请手动修改或运行:"
    echo "   sed -i 's/export MINIMAX_API_KEY=.*/export MINIMAX_API_KEY=$API_KEY/' $SHELL_RC"
    echo "   sed -i 's/export MINIMAX_GROUP_ID=.*/export MINIMAX_GROUP_ID=$GROUP_ID/' $SHELL_RC"
else
    echo "" >> "$SHELL_RC"
    echo "# MiniMax API 配置" >> "$SHELL_RC"
    echo "export MINIMAX_API_KEY='$API_KEY'" >> "$SHELL_RC"
    echo "export MINIMAX_GROUP_ID='$GROUP_ID'" >> "$SHELL_RC"
    echo "✅ 已添加配置到: $SHELL_RC"
fi

echo ""
echo "============================================"
echo "  配置完成！"
echo "============================================"
echo ""
echo "下一步:"
echo "1. 运行: source $SHELL_RC"
echo "2. 验证配置: python3 scripts/minimax_client.py config"
