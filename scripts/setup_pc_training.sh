#!/bin/bash
# =============================================================
# PC Training Setup Script for LeRobot ACT Training
# Target: Ubuntu PC with NVIDIA RTX 5060
# =============================================================
#
# What this does:
#   1. Installs miniforge (conda)
#   2. Creates 'lerobot' conda env with Python 3.12
#   3. Installs FFmpeg 7.x
#   4. Installs PyTorch with CUDA (standard wheels — no source build needed!)
#   5. Installs LeRobot from source
#   6. Verifies GPU access
#
# Usage:
#   chmod +x scripts/setup_pc_training.sh
#   ./scripts/setup_pc_training.sh
#
# After setup, copy your dataset from Jetson:
#   scp -r <user>@<JETSON_IP>:~/.cache/huggingface/lerobot/fay/shark-to-cup \
#       ~/.cache/huggingface/lerobot/fay/shark-to-cup
#
# Then train:
#   conda activate lerobot
#   lerobot-train \
#     --dataset.repo_id=fay/shark-to-cup \
#     --dataset.root=$HOME/.cache/huggingface/lerobot/fay/shark-to-cup \
#     --policy.type=act \
#     --output_dir=outputs/train/act_shark_to_cup \
#     --job_name=act_shark_to_cup \
#     --policy.device=cuda \
#     --policy.push_to_hub=false
# =============================================================

set -e

echo "=========================================="
echo "  LeRobot PC Training Setup"
echo "=========================================="

# --- Step 0: Check for NVIDIA GPU ---
echo ""
echo "[Step 0] Checking NVIDIA GPU..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
    echo "✓ NVIDIA GPU detected"
else
    echo "✗ nvidia-smi not found. Install NVIDIA drivers first:"
    echo "  sudo apt install nvidia-driver-570"
    echo "  Then reboot and re-run this script."
    exit 1
fi

# --- Step 1: Install miniforge ---
echo ""
echo "[Step 1] Installing miniforge..."
if command -v conda &> /dev/null; then
    echo "✓ conda already installed: $(conda --version)"
else
    echo "Downloading miniforge..."
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
    bash Miniforge3-Linux-x86_64.sh -b -p "$HOME/miniforge3"
    rm Miniforge3-Linux-x86_64.sh

    # Initialize conda for current shell
    eval "$($HOME/miniforge3/bin/conda shell.bash hook)"
    conda init bash
    echo "✓ miniforge installed. You may need to restart your shell after this script."
fi

# Make sure conda is available
eval "$(conda shell.bash hook 2>/dev/null || $HOME/miniforge3/bin/conda shell.bash hook)"

# --- Step 2: Create conda environment ---
echo ""
echo "[Step 2] Creating 'lerobot' conda environment..."
if conda env list | grep -q "^lerobot "; then
    echo "✓ 'lerobot' env already exists"
else
    conda create -n lerobot python=3.12 -y
    echo "✓ Created 'lerobot' env with Python 3.12"
fi

conda activate lerobot
echo "Python: $(python --version)"

# --- Step 3: Install FFmpeg 7.x ---
echo ""
echo "[Step 3] Installing FFmpeg 7.x..."
FFMPEG_VERSION=$(ffmpeg -version 2>/dev/null | head -1 | grep -oP 'ffmpeg version \K[0-9]+' || echo "0")
if [ "$FFMPEG_VERSION" = "7" ]; then
    echo "✓ FFmpeg 7.x already installed"
else
    conda install -c conda-forge ffmpeg=7.1.1 -y
    echo "✓ FFmpeg 7.x installed"
fi

# --- Step 4: Install PyTorch with CUDA ---
echo ""
echo "[Step 4] Installing PyTorch with CUDA..."
# Standard pip wheels work on desktop GPUs (unlike Jetson which needs source build)
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu126
echo "✓ PyTorch installed"

# Verify CUDA
python -c "
import torch
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'GPU: {torch.cuda.get_device_name(0)}')
    print(f'CUDA version: {torch.version.cuda}')
    # Quick test
    t = torch.tensor([1.0, 2.0, 3.0], device='cuda')
    print(f'GPU tensor test: {t * 2}  ✓')
else:
    print('WARNING: CUDA not available! Check drivers.')
    exit(1)
"

# --- Step 5: Install LeRobot from source ---
echo ""
echo "[Step 5] Installing LeRobot..."
LEROBOT_DIR="$HOME/lerobot"
if [ -d "$LEROBOT_DIR" ]; then
    echo "LeRobot directory exists, updating..."
    cd "$LEROBOT_DIR"
    git pull
else
    echo "Cloning LeRobot..."
    cd "$HOME"
    git clone https://github.com/huggingface/lerobot.git
    cd "$LEROBOT_DIR"
fi

# Install with feetech support (matches Jetson setup)
pip install -e ".[feetech]"
echo "✓ LeRobot installed"

# IMPORTANT: Verify PyTorch still has CUDA after LeRobot install
# (LeRobot's dependencies can silently replace GPU PyTorch with CPU version)
echo ""
echo "[Step 5b] Verifying PyTorch CUDA survived LeRobot install..."
CUDA_OK=$(python -c "import torch; print(torch.cuda.is_available())" 2>/dev/null)
if [ "$CUDA_OK" != "True" ]; then
    echo "⚠ LeRobot install broke CUDA PyTorch! Reinstalling..."
    pip install torch torchvision --index-url https://download.pytorch.org/whl/cu126
    echo "✓ PyTorch CUDA restored"
fi

# --- Step 6: Create dataset directory ---
echo ""
echo "[Step 6] Creating dataset directory..."
mkdir -p "$HOME/.cache/huggingface/lerobot/fay"
echo "✓ Dataset directory ready"

# --- Final verification ---
echo ""
echo "=========================================="
echo "  Setup Complete! Final Verification:"
echo "=========================================="
python -c "
import torch
import lerobot
print(f'LeRobot version: {lerobot.__version__}')
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available:  {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'GPU:             {torch.cuda.get_device_name(0)}')
    print(f'GPU memory:      {torch.cuda.get_device_properties(0).total_mem / 1e9:.1f} GB')
print()
print('All good! Next steps:')
print('  1. Copy dataset from Jetson:')
print('     scp -r <user>@<JETSON_IP>:~/.cache/huggingface/lerobot/fay/shark-to-cup \\\\')
print(f'         {\"$HOME\"}/.cache/huggingface/lerobot/fay/shark-to-cup')
print()
print('  2. Start training:')
print('     conda activate lerobot')
print('     lerobot-train \\\\')
print('       --dataset.repo_id=fay/shark-to-cup \\\\')
print(f'       --dataset.root={\"$HOME\"}/.cache/huggingface/lerobot/fay/shark-to-cup \\\\')
print('       --policy.type=act \\\\')
print('       --output_dir=outputs/train/act_shark_to_cup \\\\')
print('       --job_name=act_shark_to_cup \\\\')
print('       --policy.device=cuda \\\\')
print('       --policy.push_to_hub=false')
"
