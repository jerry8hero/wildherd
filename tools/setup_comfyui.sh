#!/bin/bash
# ComfyUI 安装脚本
# 用法: bash scripts/setup_comfyui.sh

set -e

COMFYUI_DIR="${HOME}/ComfyUI"
MODELS_DIR="${HOME}/ComfyUI/models"

echo "=========================================="
echo "  ComfyUI 安装脚本"
echo "=========================================="

# 1. 检查 NVIDIA GPU
echo ""
echo "[1/6] 检查 NVIDIA GPU..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
    echo "✓ NVIDIA GPU 检测成功"
else
    echo "✗ 未检测到 NVIDIA GPU 或驱动未安装"
    exit 1
fi

# 2. 检查 Python
echo ""
echo "[2/6] 检查 Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "✓ Python 版本: $PYTHON_VERSION"
else
    echo "✗ 未检测到 Python"
    exit 1
fi

# 3. 克隆 ComfyUI
echo ""
echo "[3/6] 克隆 ComfyUI..."
if [ -d "$COMFYUI_DIR" ]; then
    echo "  ComfyUI 已存在，跳过克隆"
else
    git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFYUI_DIR"
    echo "✓ ComfyUI 克隆完成"
fi

# 4. 安装依赖
echo ""
echo "[4/6] 安装 Python 依赖..."
cd "$COMFYUI_DIR"
pip install -r requirements.txt
echo "✓ 依赖安装完成"

# 5. 创建目录结构
echo ""
echo "[5/6] 创建目录结构..."
mkdir -p "$MODELS_DIR/checkpoints"      # SD/SDXL模型
mkdir -p "$MODELS_DIR/controlnet"       # ControlNet模型
mkdir -p "$MODELS_DIR/vae"              # VAE模型
echo "✓ 目录创建完成"

# 6. 下载模型
echo ""
echo "[6/6] 模型下载..."
echo ""
echo "=========================================="
echo "  重要: 你需要手动下载以下模型:"
echo "=========================================="
echo ""
echo "1. SDXL 1.0 (推荐)"
echo "   下载地址: https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0"
echo "   保存到: ${MODELS_DIR}/checkpoints/"
echo ""
echo "2. SD 1.5 (备选，更快)"
echo "   下载地址: https://huggingface.co/runwayml/stable-diffusion-v1-5"
echo "   保存到: ${MODELS_DIR}/checkpoints/"
echo ""
echo "3. ControlNet Lineart"
echo "   下载地址: https://huggingface.co/TheMistoAI/MistoLine"
echo "   保存到: ${MODELS_DIR}/controlnet/"
echo ""
echo "4. VAE (推荐)"
echo "   下载地址: https://huggingface.co/stabilityai/sdxl-vae"
echo "   保存到: ${MODELS_DIR}/vae/"
echo ""

# 启动说明
echo "=========================================="
echo "  启动 ComfyUI"
echo "=========================================="
echo ""
echo "下载模型后，运行以下命令启动:"
echo ""
echo "  cd $COMFYUI_DIR"
echo "  python main.py --listen 0.0.0.0 --port 8188"
echo ""
echo "启动后访问: http://localhost:8188"
echo ""

# 验证安装
echo "=========================================="
echo "  验证安装"
echo "=========================================="
echo ""
echo "运行测试:"
echo "  python3 -c \"import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.cuda.is_available()}')\""
echo ""
echo "安装完成!"
