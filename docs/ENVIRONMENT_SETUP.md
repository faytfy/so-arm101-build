# Environment Strategy

## Available Hardware
| Machine | OS | GPU | RAM | Role |
|---------|-----|-----|-----|------|
| MacBook (Apple Silicon) | macOS | MPS | — | Command center, coding, assembly |
| NVIDIA Jetson AGX Orin | Linux (JetPack) | CUDA (Orin GPU) | 64GB shared | Robot-connected hub, teleop, training, deployment |
| Desktop PC | Ubuntu | RTX 5XXX (CUDA) | — | Fast training |

## Workflow Plan
1. **Mac (Days 1–2)** — Assembly, motor config, calibration, first teleoperation. Code editing, SSH, project management throughout.
2. **Jetson AGX Orin (Day 3+)** — Arms transfer here via USB. Handles camera setup, teleoperation, data recording, and can train locally (~6hrs for ACT on 30 episodes). Primary robot-connected machine from Day 3 onward.
3. **PC (RTX 5XXX)** — Training powerhouse. Push datasets to HuggingFace Hub from Jetson, pull on PC, train policies fast, push models back. Fastest option for iteration.

## Key Findings (from community research, March 2026)

### Mac MPS — Do NOT train here
- ACT training on real robot data with cameras causes **gradient explosion → NaN loss** on Apple Silicon MPS (LeRobot GitHub Issue #1066)
- Closed as NOT_PLANNED — it's a PyTorch MPS bug, not LeRobot's
- Simulation-only training (e.g., PushT) works on MPS; real robot data does not
- CPU training works but is impractically slow

### Jetson AGX Orin — Full pipeline capable
- Documented end-to-end on [Hackster.io](https://www.hackster.io/shahizat/running-lerobot-so-101-arm-kit-using-nvidia-jetson-agx-orin-19b8a4)
- Requires building FFmpeg 7.1 from source with NVDEC (one-time, ~30 min)
- PyTorch may install without CUDA by default — need manual setup (LeRobot Issue #2363)
- JetPack 6.x + CUDA 12.8 + PyTorch 2.7.0 is a known working combo

### Training benchmarks (community-reported)
| Hardware | ACT Training Time | Notes |
|----------|------------------|-------|
| RTX 4090 / A100 | ~2-3 hrs (50 eps) | Community standard |
| RTX 3060 (8GB) | ~6 hrs (50 eps) | Minimum practical |
| Jetson AGX Orin | ~6 hrs (30 eps) | Works well |
| Cloud A100 (Colab) | ~2 hrs (50 eps) | Good if no local GPU |
| Mac MPS | Broken | Gradient bugs on real data |

### Multi-machine data flow (community standard)
```
[Jetson/Laptop] teleop + record → push dataset to HuggingFace Hub
[GPU machine]   pull dataset → train → push model to Hub
[Jetson/Robot]   pull model → run inference
```

### LeRobot requirements update
- **Python >= 3.12** now required (previously 3.10)
- **conda (miniforge)** is the recommended env manager
- **FFmpeg 7.x** with libsvtav1 encoder needed

## Setup Status
- [x] Mac: conda (miniforge), Python 3.12.13, FFmpeg 7.1.1, PyTorch 2.10.0, LeRobot 0.5.1
- [ ] Jetson AGX Orin: LeRobot + CUDA + FFmpeg
- [ ] PC: LeRobot + CUDA training environment
