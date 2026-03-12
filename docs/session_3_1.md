# Session 3.1: Jetson AGX Orin Environment Setup

## Goal
Get the Jetson ready to run LeRobot — install conda, Python 3.12, PyTorch (GPU), and LeRobot with Feetech support.

## Prerequisites
- Jetson AGX Orin accessible via SSH ✅
- JetPack 6.2.2 / CUDA 12.6 ✅

---

## 1. TEACH: Why a Separate Machine?

**Concepts:**
- Why we move from Mac to Jetson for teleoperation, recording, and training
- GPU matters: CUDA vs MPS — what the Jetson GPU gives us
- The Jetson's role in the robot pipeline: teleop + record + train (+ deploy)
- Why we still keep the Mac as a dev/coding station

---

## 2. TEACH: Jetson vs Desktop GPU vs Mac

**Concepts:**
- Jetson = ARM + NVIDIA GPU on one board (like a GPU-powered Raspberry Pi)
- CUDA 12.6 = full NVIDIA ML stack, unlike Mac's MPS (limited, buggy for robotics)
- 64GB unified memory = GPU and CPU share the same RAM pool (no separate VRAM)
- JetPack = NVIDIA's Linux distro with drivers, CUDA, cuDNN pre-installed
- Why LeRobot works better here: PyTorch CUDA, camera drivers, USB latency

---

## 3. DO: Install Miniforge (conda)

LeRobot requires Python >= 3.12. The Jetson ships with 3.10. We'll use conda (miniforge) just like on the Mac.

```bash
# Download miniforge for aarch64
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh

# Install
bash Miniforge3-Linux-aarch64.sh -b -p ~/miniforge3

# Initialize
~/miniforge3/bin/conda init bash

# Reload shell
source ~/.bashrc

# Verify
conda --version
python --version
```

---

## 4. DO: Create lerobot conda environment

```bash
conda create -n lerobot python=3.12 -y
conda activate lerobot
python --version  # Should be 3.12.x
```

---

## 5. DO: Install PyTorch for Jetson

**NOTE:** As of JetPack 6.2+, PyTorch's official CUDA index has aarch64 wheels for Python 3.12. No NVIDIA-specific wheels needed.

```bash
# Install PyTorch with CUDA 12.6 support
pip install torch==2.10.0+cu126 torchvision==0.25.0+cu126 --index-url https://download.pytorch.org/whl/cu126

# Verify GPU support
python -c "import torch; print(torch.cuda.is_available()); print(torch.cuda.get_device_name(0))"
```

**WARNING:** Do NOT use the default PyPI index (`pip install torch` without `--index-url`) — it installs a CPU-only build.

---

## 6. DO: Install FFmpeg 7.x

LeRobot requires FFmpeg 7.x (not 8.x).

```bash
# Check what's available
ffmpeg -version 2>/dev/null

# Install via conda if needed
conda install -c conda-forge 'ffmpeg>=7,<8' -y
```

---

## 7. DO: Install LeRobot from source

```bash
cd ~
git clone https://github.com/huggingface/lerobot.git
cd lerobot
pip install -e ".[feetech]"

# Verify
python -c "import lerobot; print(lerobot.__version__)"
```

**IMPORTANT:** After installing lerobot, verify PyTorch still has CUDA:
```bash
python -c "import torch; print('CUDA:', torch.cuda.is_available())"
```
If CUDA is gone, pip replaced the Jetson PyTorch with a CPU version — reinstall the Jetson wheel.

---

## 8. DO: Verify full stack

```bash
python -c "
import torch
import lerobot
print(f'LeRobot: {lerobot.__version__}')
print(f'PyTorch: {torch.__version__}')
print(f'CUDA: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'GPU: {torch.cuda.get_device_name(0)}')
"
```

---

## Checkpoint
- [x] conda + Python 3.12 installed
- [x] PyTorch with CUDA support verified
- [x] FFmpeg 7.x installed
- [x] LeRobot installed with Feetech support
- [x] Full stack verification passed
