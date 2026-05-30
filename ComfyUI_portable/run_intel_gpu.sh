#!/usr/bin/env bash
# run_intel_gpu.sh - Linux Intel GPU 启动脚本 (ComfyUI)
# 对应 Windows 版的 run_intel_gpu.bat，仅修改 Linux 特有部分

# ==================== XPU 优化配置 ====================
export SYCL_CACHE_PERSISTENT=1
export SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1
export PYTORCH_DEVICE=xpu
export TORCH_COMPILE_BACKEND=eager
export TOKENIZERS_PARALLELISM=false

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

VENV_DIR="$SCRIPT_DIR/venv"

# === 首次运行：自动创建虚拟环境（对应 Windows 的 python_embeded/）===
if [ ! -f "$VENV_DIR/bin/python" ]; then
    echo "========================================"
    echo "初次运行：正在创建 Python 虚拟环境..."
    echo "========================================"

    # 检测 python3
    if ! command -v python3 &> /dev/null; then
        echo "错误：未找到 python3，请先安装 Python 3.12+"
        echo "例如: sudo apt install python3 python3-venv python3-pip"
        read -p "按回车键退出..."
        exit 1
    fi

    python3 -m venv "$VENV_DIR"
    if [ $? -ne 0 ]; then
        echo "错误：创建虚拟环境失败，请确保已安装 python3-venv"
        echo "例如: sudo apt install python3-venv"
        read -p "按回车键退出..."
        exit 1
    fi

    echo ""
    echo "正在安装 Intel PyTorch (xpu)..."
    "$VENV_DIR/bin/pip" install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/xpu
    if [ $? -ne 0 ]; then
        echo "警告：Intel PyTorch 安装失败，可稍后手动安装"
    fi

    echo ""
    echo "正在安装 ComfyUI 依赖..."
    "$VENV_DIR/bin/pip" install -r "$SCRIPT_DIR/ComfyUI/requirements.txt"
    if [ $? -ne 0 ]; then
        echo "警告：部分依赖安装失败，请检查 requirements.txt"
    fi

    echo ""
    echo "========================================"
    echo "环境初始化完成！"
    echo "========================================"
    echo ""
fi

# === 启动 ComfyUI（对应 run_intel_gpu.bat 的核心命令）===
#  Windows: .\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build
#  Linux:   使用 venv 替代 python_embeded，去掉 --windows-standalone-build
echo "正在启动 ComfyUI (Intel GPU)..."
"$VENV_DIR/bin/python" -s "$SCRIPT_DIR/ComfyUI/main.py"

echo ""
read -p "按回车键退出..."
