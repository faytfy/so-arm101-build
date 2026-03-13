# Bonus Handout: PC Training Setup & GPU Architecture Lessons

## The Problem: Two GPUs, Same Error, Different Fixes

Both the Jetson Orin and the RTX 5060 Ti hit the same error:
```
CUDA error: no kernel image is available for execution on the device
```

But the **root cause** and **fix** were completely different:

| | Jetson AGX Orin | Desktop RTX 5060 Ti |
|---|---|---|
| **Architecture** | Ampere (sm_87) | Blackwell (sm_120) |
| **Problem** | sm_87 not in any PyTorch wheel | sm_120 not in PyTorch 2.10 wheels |
| **Fix** | Build PyTorch from source (~6hr build) | Install PyTorch 2.7.0+cu128 (`pip install`) |
| **Why the difference** | Jetson is niche — PyTorch never includes sm_87 | Desktop is priority — PyTorch added sm_120 in 2.7 |
| **Time to fix** | ~6 hours | ~2 minutes |

---

## What Is SM (Streaming Multiprocessor)?

The **SM version** identifies a GPU's architecture. Each SM version has different instruction sets, and CUDA code must be compiled for the specific SM version it runs on.

| SM Version | Architecture | Example GPUs |
|---|---|---|
| sm_50 | Maxwell | GTX 950 |
| sm_60 | Pascal | GTX 1080 |
| sm_70 | Volta | V100 (data center) |
| sm_75 | Turing | RTX 2080 |
| sm_80 | Ampere | A100, RTX 3090 |
| sm_86 | Ampere (minor rev) | RTX 3060 |
| sm_87 | Ampere (Jetson) | Jetson Orin |
| sm_90 | Hopper | H100 (data center) |
| sm_120 | Blackwell | RTX 5060 Ti |

**Key insight:** GPU code compiled for sm_80 will NOT run on sm_87 or sm_120. Each architecture needs its own compiled kernels, and PyTorch wheels only include kernels for architectures they choose to support.

---

## Why Desktop GPUs Get Better PyTorch Support

PyTorch is maintained by **Meta**, not NVIDIA. Meta prioritizes:
1. Their own data center GPUs (A100, H100)
2. The research community's desktop GPUs (RTX series)
3. Edge/embedded devices like Jetson — low priority

**The economics:**
- Desktop GPUs: millions of users, billions in revenue
- Jetson: thousands of users, much smaller market
- Result: desktop gets pre-built wheels on release day, Jetson gets "build it yourself"

---

## Training Speed Comparison

| | Jetson AGX Orin | Desktop RTX 5060 Ti |
|---|---|---|
| CUDA cores | 2,048 | ~4,608 |
| Memory | 64 GB unified (shared CPU+GPU) | 8 GB dedicated VRAM |
| Training speed | ~1.14s/step | ~0.18s/step |
| 100K steps | ~33 hours | ~5 hours |
| **Speedup** | baseline | **6.3x faster** |

The RTX 5060 Ti is faster despite having less memory because:
1. **Dedicated VRAM** has higher bandwidth than Jetson's unified memory
2. **More CUDA cores** for parallel computation
3. **Higher clock speeds** (desktop GPUs aren't power-constrained)

---

## When to Use Which Machine

| Machine | Best For | Why |
|---|---|---|
| **PC (RTX 5060 Ti)** | Training | 6x faster, standard PyTorch, no edge constraints |
| **Jetson** | Inference (running policy on robot) | Arms already connected, portable, low power |
| **Either** | Inference | Any machine with USB ports can run inference |

**The practical workflow:**
1. Record demos on Jetson (arms + cameras connected)
2. Copy dataset to PC: `scp -r <user>@<JETSON_IP>:~/.cache/huggingface/lerobot/fay/shark-to-cup ~/.cache/huggingface/lerobot/fay/`
3. Train on PC (fast)
4. Copy checkpoint to Jetson: `scp -r outputs/train/act_shark_to_cup/checkpoints/last <user>@<JETSON_IP>:~/outputs/train/act_shark_to_cup/checkpoints/`
5. Run inference on Jetson

---

## PC Setup Summary

What we installed on the desktop PC (<PC_IP>):

1. **openssh-server** — for remote access
2. **miniforge** — conda package manager
3. **conda env `lerobot`** — Python 3.12
4. **FFmpeg 7.1.1** — video encoding/decoding
5. **PyTorch 2.7.0+cu128** — with Blackwell sm_120 support
6. **LeRobot 0.5.1** — from source with feetech support

### Issues Encountered
- **torchcodec incompatibility:** Built for PyTorch 2.10, doesn't work with 2.7. Fix: use `--dataset.video_backend=pyav`
- **SSH key setup:** Needed to manually add Mac's public key to PC's authorized_keys

### Training Command (PC)
```bash
conda activate lerobot
lerobot-train \
  --dataset.repo_id=fay/shark-to-cup \
  --dataset.root=$HOME/.cache/huggingface/lerobot/fay/shark-to-cup \
  --dataset.video_backend=pyav \
  --policy.type=act \
  --output_dir=$HOME/outputs/train/act_shark_to_cup \
  --job_name=act_shark_to_cup \
  --policy.device=cuda \
  --policy.push_to_hub=false
```

---

## Q&A From This Session

**Q: Do we actually need the Jetson, or can we just use the PC?**
A: For learning and prototyping, the PC can do everything. Jetson matters for deployment — when the robot needs a small, portable, dedicated brain (factory floor, mobile robots, demos). Think of PC as the workshop, Jetson as the embedded brain.

**Q: Why was the PC fix so much easier than the Jetson fix?**
A: Market economics. Desktop GPUs have millions of users demanding PyTorch support, so Meta includes sm_120 in pre-built wheels. Jetson has thousands of users, so sm_87 is never included — you must build from source.

**Q: What does SM mean?**
A: Streaming Multiprocessor — the basic compute building block of an NVIDIA GPU. The sm_XX number identifies the architecture version, and CUDA code must be compiled for the specific version it runs on.

**Q: Will the PC sleep and interrupt training?**
A: No — checked `gsettings` and confirmed `sleep-inactive-ac-type` is set to `'nothing'` (no auto-sleep when plugged in).

---

## Vocabulary

| Term | Definition |
|---|---|
| **SM (Streaming Multiprocessor)** | Basic compute unit of an NVIDIA GPU; the sm_XX number identifies the architecture version |
| **CUDA kernel** | A function compiled to run on the GPU; must be compiled for the specific SM version |
| **Pre-built wheel** | A ready-to-install Python package (no compilation needed) |
| **Build from source** | Compiling code yourself from raw source files — needed when pre-built wheels don't support your hardware |
| **cu126 / cu128** | PyTorch wheel variants compiled against CUDA 12.6 or 12.8 respectively |
| **Blackwell** | NVIDIA's latest GPU architecture (2025), used in RTX 50-series (sm_120) |
| **Unified memory** | Jetson's architecture where CPU and GPU share the same RAM pool — bigger capacity but slower bandwidth |
| **Dedicated VRAM** | Desktop GPU memory exclusive to the GPU — smaller but faster bandwidth |
| **torchcodec** | Video decoder library; version-locked to specific PyTorch versions |
| **pyav** | Alternative video decoder that works across PyTorch versions |
