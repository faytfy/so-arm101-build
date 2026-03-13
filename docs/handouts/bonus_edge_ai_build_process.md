# Bonus Handout: The Edge AI Build Problem

## Why We Had to Build PyTorch from Source

### The Problem
PyTorch ships pre-built binaries (wheels) with GPU kernels compiled for popular GPUs:
- sm_80 (A100, data center)
- sm_90 (H100, data center)
- sm_86 (RTX 3090, desktop)
- sm_89 (RTX 4090, desktop)

Our Jetson AGX Orin has compute capability **sm_87** — not included in the standard wheels. When training tried to run GPU operations, it found no matching kernel and crashed:
```
torch.AcceleratorError: CUDA error: no kernel image is available for execution on the device
```

The sneaky part: `torch.cuda.is_available()` returns True (CUDA runtime loads fine), but actual kernel execution fails.

### Why the Gap Exists
1. **Build matrix explosion** — every extra GPU target multiplies build time and storage for package maintainers
2. **Small user base** — 95% of PyTorch users are on desktop/cloud GPUs
3. **Split responsibility** — NVIDIA is expected to provide Jetson-specific wheels, but they often lag behind on newer Python versions (e.g., they have Python 3.10 wheels but not 3.12)

### What We Did: Build from Source

```
Source Code (.cpp, .cu files)
       │
       ├── C++ files (.cpp) → GCC compiler → CPU code (.o files)
       │                                      Runs on ARM cores
       │
       └── CUDA files (.cu) → NVCC compiler → GPU code (.o files)
                                │              Runs on Orin GPU
                                │
                                └── TORCH_CUDA_ARCH_LIST=8.7
                                    "generate instructions for
                                    the Orin's specific GPU"
       │
       └── All .o files linked together → torch library → .whl package
```

Key environment variables:
- `TORCH_CUDA_ARCH_LIST=8.7` — the critical one; tells nvcc which GPU to target
- `CUDA_HOME=/usr/local/cuda` — where the CUDA toolkit lives
- `CUDACXX=/usr/local/cuda/bin/nvcc` — path to the CUDA compiler
- `USE_NCCL=0, USE_DISTRIBUTED=0` — skip multi-GPU features we don't need
- `MAX_JOBS=4` — parallel compilation (balance speed vs memory)

### Why CUDA Kernels Compile Slowly
- **nvcc is slower than gcc** — GPU code optimization is more complex
- **Flash Attention kernels** are hand-optimized with many template specializations
- Each variant compiles separately: different data types (fp16, bf16) × different dimensions (64, 128, 256) = many files
- The build had 5941 total steps; CUDA kernels dominated the compile time

### How Common Is This?
**Extremely common.** Top 3 complaint in Jetson developer forums. The typical journey:
1. "Just `pip install torch`!" → looks great
2. `torch.cuda.is_available()` → True!
3. Actually run training → "no kernel image available" → confusion
4. Hours of debugging → build from source
5. Finally works

### Beyond Jetson
The same problem appears with:
- **RTX 5060 (Blackwell)** — so new that wheels may not have sm_100 kernels
- **Raspberry Pi AI accelerators** — different compilers entirely
- **Qualcomm Snapdragon** (drones/phones) — no CUDA, different frameworks
- **Custom FPGA/ASIC** — everything compiled from scratch

### The Takeaway
The closer you are to mainstream hardware, the easier the software stack. Edge AI = powerful capabilities in small packages, but you pay with build complexity. Building PyTorch from source is a rite of passage for edge AI developers.

## Top 3 Pain Points in the Jetson Developer Community

### 1. PyTorch/ML Framework Compatibility (#1 by far)
- NVIDIA releases new JetPack → PyTorch releases new version → the two don't align
- Missing wheels, Python version mismatches, CUDA version conflicts
- Developers spend days getting the software stack working before doing any AI work
- Root cause: Jetson sits between two worlds — ARM computer (like a phone) running desktop-class AI software (built for x86 servers). Every library (PyTorch, torchvision, OpenCV, FFmpeg) must work on ARM + CUDA, and any one break kills the chain
- **We hit this directly:** standard PyTorch wheels lacked sm_87 kernels for our Orin

### 2. Memory Management on Unified Memory
- CPU and GPU share the same 64GB memory pool — no separate VRAM
- **Blessing:** load bigger models than dedicated GPU VRAM would allow
- **Curse:** CPU and GPU operations compete for bandwidth; training can cause the system to swap or OOM-kill processes unexpectedly
- No clear "GPU memory full" error like on desktop — the whole system slows down or crashes
- Developers constantly juggle batch sizes, model sizes, and system services
- Relevant for us: if training uses too much memory, Jetson might kill the process silently

### 3. Camera/Sensor Pipeline Latency
- Getting camera frames from sensor → GPU → inference → motor output fast enough for real-time control
- V4L2 (Linux video driver) quirks: cameras behave differently on Jetson vs desktop Linux
- USB cameras add latency vs CSI cameras (which plug directly into Jetson board)
- Developers often hit 100-200ms latency when they need <30ms for real-time robotics
- We experienced this partially: camera index discovery differed between Mac and Jetson

### Honorable Mentions
- **Power management** — Jetson has multiple power modes (15W, 30W, 50W); forgetting to set max power before training = "why is this so slow?"
- **Container vs native** — NVIDIA pushes Docker containers as the "easy" path, but they add complexity and don't always work with USB devices like motor controllers
- **JetPack upgrades breaking everything** — upgrading JetPack often requires rebuilding the entire software stack

## Vocabulary
| Term | Definition |
|------|-----------|
| **Compute capability (sm_XX)** | Version number for a GPU's instruction set; determines which compiled kernels can run on it |
| **CUDA kernel** | Small program compiled to run on the GPU; operations like matrix multiply each have their own kernel |
| **nvcc** | NVIDIA's CUDA compiler; turns .cu source files into GPU machine code |
| **Wheel (.whl)** | Python package format; a zip file containing compiled code ready to install |
| **Forward compatibility** | Newer GPUs running code compiled for older ones (sm_80 code on sm_87 hardware); works with PTX but not always with cubin |
| **PTX** | Portable intermediate GPU code; forward-compatible but slower than native cubin |
| **cubin** | Native compiled GPU binary; fast but locked to specific compute capability |
| **Flash Attention** | Highly optimized attention implementation; complex CUDA kernels with many variants |
| **Build from source** | Compiling software yourself from raw code instead of using pre-built packages |
