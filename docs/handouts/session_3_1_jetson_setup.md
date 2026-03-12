# Session 3.1 Handout: Jetson AGX Orin Environment Setup

## Concepts

### Why Move to Jetson?
- **CUDA GPU** — PyTorch and the ML ecosystem are built around NVIDIA CUDA. Mac's MPS is incomplete and buggy for robotics training.
- **Real-time control** — Jetson is designed for embedded robotics: low USB latency, camera drivers, tight motor timing.
- **Unified pipeline** — The Jetson becomes the robot's "brain" for teleop, recording, training, and deployment.
- Mac stays useful as a coding/SSH station.

### Jetson Architecture
- ARM processor + NVIDIA GPU on one board (like a GPU-powered Raspberry Pi)
- **Unified memory**: CPU and GPU share the same 64GB RAM pool (no separate VRAM)
  - Pro: Can load bigger models (up to ~64GB) since there's no VRAM limit
  - Con: Memory bandwidth is slower than dedicated VRAM on a desktop GPU
- **JetPack**: NVIDIA's "batteries included" Linux distro — includes drivers, CUDA, cuDNN pre-installed

### Machine Roles in This Project

| Machine | Role | GPU |
|---|---|---|
| Mac | Coding, SSH, assembly | MPS (limited) |
| Jetson AGX Orin | Teleop, record, train, deploy | CUDA (Orin) |
| PC (RTX 5XXX) | Fast bulk training | CUDA (desktop) |

## Q&A

**Q: Why can't we just train on the Mac if it has a GPU too?**
A: (Mentee) "The framework is not perfectly designed for being the computing power for LeRobot robotic use case." Correct — Apple's MPS support in PyTorch is incomplete. Specific operations LeRobot uses will crash or silently produce wrong results on MPS.

**Q: Your Jetson has 64GB unified memory. A desktop PC has 32GB RAM + 16GB VRAM. Which can load a larger model into the GPU?**
A: (Mentee) "Jetson because its CPU and GPU share the same memory." Correct — the Jetson can use up to ~64GB for a model since it's all one pool, while the desktop is capped at 16GB VRAM. Tradeoff: dedicated VRAM has faster bandwidth, so the desktop trains faster on models that fit.

## What We Installed

| Component | Version | Method |
|---|---|---|
| Miniforge (conda) | Latest | Direct download (aarch64) |
| Python | 3.12.13 | conda create -n lerobot python=3.12 |
| PyTorch | 2.10.0+cu126 | `pip install --index-url https://download.pytorch.org/whl/cu126` |
| FFmpeg | 7.1.1 | conda install -c conda-forge |
| LeRobot | 0.5.1 | git clone + `pip install -e ".[feetech]"` |

### Key Discovery
PyTorch now ships official aarch64 CUDA wheels on their standard index (`download.pytorch.org/whl/cu126`). The old advice to use NVIDIA's Jetson-specific wheels is no longer necessary for JetPack 6.2+.

### Critical Gotcha
Installing LeRobot via pip can silently replace the CUDA PyTorch with a CPU-only version. Always verify after install:
```python
import torch
print(torch.cuda.is_available())  # Must be True
print(torch.__version__)          # Must show +cu126, not +cpu
```

## Vocabulary

| Term | Definition |
|---|---|
| **CUDA** | NVIDIA's GPU computing platform — the standard for ML training |
| **MPS** | Metal Performance Shaders — Apple's GPU framework, limited PyTorch support |
| **JetPack** | NVIDIA's Linux distribution for Jetson boards (drivers + CUDA + cuDNN) |
| **Unified memory** | CPU and GPU share the same physical RAM (Jetson, Apple Silicon) |
| **VRAM** | Video RAM — dedicated GPU memory on desktop graphics cards |
| **aarch64** | ARM 64-bit architecture (used by Jetson and Apple Silicon) |
| **x86_64** | Intel/AMD 64-bit architecture (used by desktop PCs) |
| **cuDNN** | NVIDIA's library of optimized neural network operations |
